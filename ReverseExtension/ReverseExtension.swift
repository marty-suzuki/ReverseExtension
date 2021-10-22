//
//  ReverseExtension.swift
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

import UIKit

extension UITableView {
    private struct AssociatedKey {
        static var re: UInt8 = 0
        static var isReversed: UInt8 = 0
    }
    
    private var isReversed: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.isReversed, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let isReversed = objc_getAssociatedObject(self, &AssociatedKey.isReversed) as? Bool else {
                objc_setAssociatedObject(self, &AssociatedKey.isReversed, false, .OBJC_ASSOCIATION_ASSIGN)
                return false
            }
            return isReversed
        }
    }
    
    public var re: ReverseExtension {
        guard let re = objc_getAssociatedObject(self, &AssociatedKey.re) as? ReverseExtension else {
            let re = ReverseExtension(self)
            objc_setAssociatedObject(self, &AssociatedKey.re, re, .OBJC_ASSOCIATION_RETAIN)
            isReversed = true
            return re
        }
        return re
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil && isReversed {
            re.contentInsetObservation = nil
        }
    }
}

extension UITableViewCell {
    private struct AssociatedKey {
        static var frameObservation: UInt8 = 0
    }
    
    var frameObservation: NSKeyValueObservation? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.frameObservation) as? NSKeyValueObservation
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.frameObservation, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let _ = newSuperview else {
            frameObservation = nil
            return
        }
    }
}

extension UITableView {
    public final class ReverseExtension: NSObject {
        private(set) weak var base: UITableView?
        fileprivate var nonNilBase: UITableView {
            base ?? { fatalError("base is nil") }()
        }
        
        // MARK: - Delegate
        private var delegateProxy: UITableViewDelegateProxy? {
            didSet {
                base?.delegate = delegateProxy
            }
        }
        public weak var delegate: UITableViewDelegate? {
            didSet {
                guard let delegate = delegate else {
                    delegateProxy = nil
                    return
                }

                delegateProxy = UITableViewDelegateProxy(
                    delegates: [delegate, self],
                    denyList: denied(delegate) {
                        let newerDenyList: [Selector]
                        if #available(iOS 11, *) {
                            newerDenyList = [
                                #selector($0.tableView(_:trailingSwipeActionsConfigurationForRowAt:)),
                                #selector($0.tableView(_:leadingSwipeActionsConfigurationForRowAt:))
                            ]
                        } else {
                            newerDenyList = []
                        }
                        return [
                            #selector($0.tableView(_:willDisplay:forRowAt:)),
                            #selector($0.tableView(_:willDisplayHeaderView:forSection:)),
                            #selector($0.tableView(_:willDisplayFooterView:forSection:)),
                            #selector($0.tableView(_:heightForHeaderInSection:)),
                            #selector($0.tableView(_:estimatedHeightForFooterInSection:)),
                            #selector($0.tableView(_:editingStyleForRowAt:)),
                            #selector($0.tableView(_:viewForHeaderInSection:)),
                            #selector($0.tableView(_:viewForFooterInSection:)),
                            #selector($0.tableView(_:didSelectRowAt:))
                        ] + newerDenyList
                    }
                )
            }
        }
        public weak var dataSource: UITableViewDataSource? {
            didSet {
                base?.dataSource = self
            }
        }
        
        // MARK: - reachedBottom
        private lazy var _reachedBottom: Bool = base.map { $0.contentOffset.y <= 0 } ?? false
        fileprivate(set) var reachedBottom: Bool {
            set {
                let oldValue = _reachedBottom
                _reachedBottom = newValue
                if _reachedBottom == oldValue { return }
                guard let base = base, _reachedBottom else { return }
                scrollViewDidReachBottom?(base)
            }
            get {
                _reachedBottom
            }
        }
        public var scrollViewDidReachBottom: ((UIScrollView) -> ())?
        
        // MARK: - reachedTop
        private lazy var _reachedTop = base
            .map { $0.contentOffset.y >= max(0, $0.contentSize.height - $0.bounds.size.height) } ?? false
        fileprivate(set) var reachedTop: Bool {
            set {
                let oldValue = _reachedTop
                _reachedTop = newValue
                if _reachedTop == oldValue { return }
                guard let base = base, _reachedTop else { return }
                scrollViewDidReachTop?(base)
            }
            get {
                return _reachedTop
            }
        }
        public var scrollViewDidReachTop: ((UIScrollView) -> ())?
        
        private var lastScrollIndicatorInsets: UIEdgeInsets?
        private var lastContentInset: UIEdgeInsets?
        private var mutex = pthread_mutex_t()
        fileprivate lazy var contentInsetObservation: NSKeyValueObservation? = base.map { base in
            let changeHandler: (UITableView, NSKeyValueObservedChange<UIEdgeInsets>) -> Void = { [weak self] _, _ in
                DispatchQueue.main.async {
                    self?.configureTableViewInsets()
                }
            }
            if #available(iOS 11, *) {
                return base.observe(\.safeAreaInsets, options: .new, changeHandler: changeHandler)
            } else {
                return base.observe(\.contentInset, options: .new, changeHandler: changeHandler)
            }
        }
        
        deinit {
            pthread_mutex_destroy(&mutex)
        }

        private func denied<T: NSObjectProtocol>(
            _ delegate: T,
            selector: (T) -> [Selector]
        ) -> [DenyDelegateMethod] {
            selector(delegate).map { DenyDelegateMethod(delegate: delegate, selector: $0) }
        }

        // MARK: - Initializer
        fileprivate init(_ base: UITableView) {
            self.base = base
            super.init()
            pthread_mutex_init(&self.mutex, nil)
            configureTableView(base)
        }
        
        // MARK: - UITableView configuration
        private func configureTableView(_ tableView: UITableView) {
            if tableView.transform == CGAffineTransform.identity {
                tableView.transform = CGAffineTransform.identity.rotated(by: .pi)
            }
            _ = contentInsetObservation
        }
        
        private func configureTableViewInsets() {
            defer {
                pthread_mutex_unlock(&mutex)
            }
            pthread_mutex_lock(&mutex)
            guard let base = base else { return }
            if let _ = self.lastContentInset, let _ = self.lastScrollIndicatorInsets {
                return
            }
            let contentInset: UIEdgeInsets
            if #available(iOS 11, *) {
                contentInset = base.safeAreaInsets
            } else {
                contentInset = base.contentInset
            }
            base.contentInset.bottom = contentInset.top
            base.contentInset.top = contentInset.bottom
            self.lastContentInset = base.contentInset

            let scrollIndicatorInsets = base.scrollIndicatorInsets
            base.scrollIndicatorInsets.bottom = scrollIndicatorInsets.top
            base.scrollIndicatorInsets.top = scrollIndicatorInsets.bottom
            base.scrollIndicatorInsets.right = base.bounds.size.width - 8
            self.lastScrollIndicatorInsets = base.scrollIndicatorInsets
        }
        
        fileprivate func configureCell(_ cell: UITableViewCell?) {
            guard let cell = cell else { return }
            for view in cell.subviews where String(describing: view).contains("Confirm") {
                if view.transform == CGAffineTransform.identity {
                    DispatchQueue.main.async {
                        //UIView.setAnimationsEnabled(false)
                        view.transform = CGAffineTransform.identity.rotated(by: .pi)
                        //UIView.setAnimationsEnabled(true)
                    }
                }
            }
        }
        
        // MARK: - Reverse method
        func reversedSection(with section: Int) -> Int {
            return max(0, max(0, (nonNilBase.numberOfSections - 1)) - section)
        }
        
        func reversedIndexPath(with indexPath: IndexPath, fromReversed reversed: Bool = false) -> IndexPath {
            let base = nonNilBase
            let section = max(0, max(0, (base.numberOfSections - 1)) - indexPath.section)
            let numberOfRowsInSection = base.numberOfRows(inSection: reversed ? section : indexPath.section)
            let row = reversed ? max(0, numberOfRowsInSection - 1 - indexPath.row) : indexPath.row
            return IndexPath(row: row, section: section)
        }
        
        // MAKR: - UITableView Proxy
        public func numberOfRows(inSection section: Int) -> Int {
            let section = reversedSection(with: section)
            return nonNilBase.numberOfRows(inSection: section)
        }
        
        public func rect(forSection section: Int) -> CGRect {
            let section = reversedSection(with: section)
            return nonNilBase.rect(forSection: section)
        }
        
        public func rectForHeader(inSection section: Int) -> CGRect {
            let section = reversedSection(with: section)
            return nonNilBase.rectForHeader(inSection: section)
        }
        
        public func rectForFooter(inSection section: Int) -> CGRect {
            let section = reversedSection(with: section)
            return nonNilBase.rectForFooter(inSection: section)
        }
        
        public func rectForRow(at indexPath: IndexPath) -> CGRect {
            let indexPath = reversedIndexPath(with: indexPath)
            return nonNilBase.rectForRow(at: indexPath)
        }
        
        public func indexPathForRow(at point: CGPoint) -> IndexPath? {
            guard let indexPath = base?.indexPathForRow(at: point) else { return nil }
            return reversedIndexPath(with: indexPath)
        }
        
        public func indexPath(for cell: UITableViewCell) -> IndexPath? {
            guard let indexPath = base?.indexPath(for: cell) else { return nil }
            return reversedIndexPath(with: indexPath)
        }
        
        public func indexPathsForRows(in rect: CGRect) -> [IndexPath]? {
            return base?.indexPathsForRows(in: rect)?.map { reversedIndexPath(with: $0) }
        }
        
        public func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
            let indexPath = reversedIndexPath(with: indexPath)
            return base?.cellForRow(at: indexPath)
        }
        
        public var indexPathsForVisibleRows: [IndexPath]? {
            return base?.indexPathsForVisibleRows?.map { reversedIndexPath(with: $0) }
        }
        
        public func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
            let section = reversedSection(with: section)
            return base?.headerView(forSection: section)
        }
        
        public func footerView(forSection section: Int) -> UITableViewHeaderFooterView? {
            let section = reversedSection(with: section)
            return base?.footerView(forSection: section)
        }
        
        public func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
            let indexPath = reversedIndexPath(with: indexPath, fromReversed: true)
            base?.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
        
        public func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
            let newSections = IndexSet(sections.map { reversedSection(with: $0) })
            base?.insertSections(newSections, with: animation)
        }
        
        public func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
            let newSections = IndexSet(sections.map { reversedSection(with: $0) })
            base?.deleteSections(newSections, with: animation)
        }
        
        public func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
            let newSections = IndexSet(sections.map { reversedSection(with: $0) })
            base?.reloadSections(newSections, with: animation)
        }
        
        public func moveSection(_ section: Int, toSection newSection: Int) {
            let section = reversedSection(with: section)
            let newSection = reversedSection(with: newSection)
            base?.moveSection(section, toSection: newSection)
        }
        
        public func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            let newIndexPaths = indexPaths.map { reversedIndexPath(with: $0, fromReversed: true) }
            base?.insertRows(at: newIndexPaths, with: animation)
        }
        
        public func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            let newIndexPaths = indexPaths.map { reversedIndexPath(with: $0, fromReversed: true) }
            base?.deleteRows(at: newIndexPaths, with: animation)
        }
        
        public func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            let newIndexPaths = indexPaths.map { reversedIndexPath(with: $0, fromReversed: true) }
            base?.reloadRows(at: newIndexPaths, with: animation)
        }
        
        public func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
            let indexPath = reversedIndexPath(with: indexPath, fromReversed: true)
            let newIndexPath = reversedIndexPath(with: newIndexPath, fromReversed: true)
            base?.moveRow(at: indexPath, to: newIndexPath)
        }
        
        public var indexPathForSelectedRow: IndexPath? {
            guard let indexPath = base?.indexPathForSelectedRow else { return nil }
            return reversedIndexPath(with: indexPath)
        }
        
        public var indexPathsForSelectedRows: [IndexPath]? {
            return base?.indexPathsForSelectedRows?.map { reversedIndexPath(with: $0) }
        }
        
        public func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
            let newIndexPath: IndexPath?
            if let indexPath = indexPath {
                newIndexPath = reversedIndexPath(with: indexPath, fromReversed: true)
            } else {
                newIndexPath = nil
            }
            base?.selectRow(at: newIndexPath, animated: animated, scrollPosition: scrollPosition)
        }
        
        public func deselectRow(at indexPath: IndexPath, animated: Bool) {
            let indexPath = reversedIndexPath(with: indexPath, fromReversed: true)
            base?.deselectRow(at: indexPath, animated: animated)
        }
        
        public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
            let indexPath = reversedIndexPath(with: indexPath, fromReversed: true)
            return nonNilBase.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
    }
}

extension UITableView.ReverseExtension: UITableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let hasContent = scrollView.contentSize.height > 0
        reachedBottom = scrollView.contentOffset.y <= 0 && hasContent
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        reachedTop = scrollView.contentOffset.y >= maxScrollDistance && hasContent
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.frameObservation = cell.observe(\.frame, options: .new) { [weak self] cell, change in
            DispatchQueue.global().async {
                guard let x = change.newValue?.origin.x, x > 0 else {
                    return
                }
                let time = DispatchTime.now() + .milliseconds(10)
                DispatchQueue.global().asyncAfter(deadline: time) { [weak cell] in
                    self?.configureCell(cell)
                }
            }
        }
        
        if cell.contentView.transform == CGAffineTransform.identity {
            UIView.setAnimationsEnabled(false)
            cell.contentView.transform = CGAffineTransform.identity.rotated(by: .pi)
            UIView.setAnimationsEnabled(true)
        }

        delegate?.tableView?(tableView, willDisplay: cell, forRowAt: reversedIndexPath(with: indexPath))
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view.transform == CGAffineTransform.identity {
            UIView.setAnimationsEnabled(false)
            view.transform = CGAffineTransform.identity.rotated(by: .pi)
            UIView.setAnimationsEnabled(true)
        }

        delegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: reversedSection(with: section))
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if view.transform == CGAffineTransform.identity {
            UIView.setAnimationsEnabled(false)
            view.transform = CGAffineTransform.identity.rotated(by: .pi)
            UIView.setAnimationsEnabled(true)
        }

        delegate?.tableView?(tableView, willDisplayFooterView: view, forSection: reversedSection(with: section))
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        delegate?.tableView?(tableView, heightForHeaderInSection: reversedSection(with: section)) ?? .leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        delegate?.tableView?(tableView, heightForFooterInSection: reversedSection(with: section)) ?? .leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        delegate?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? .delete
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        delegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        delegate?.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }
}

extension UITableView.ReverseExtension: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { fatalError("dataSource is nil") }
        return dataSource.tableView(tableView, numberOfRowsInSection: reversedSection(with: section))
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else { fatalError("dataSource is nil") }
        return dataSource.tableView(tableView, cellForRowAt: reversedIndexPath(with: indexPath))
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {// Default is 1 if not implemented
        return dataSource?.numberOfSections?(in: tableView) ?? 1
    }

    // fixed font style. use custom view (UILabel) if you want something different
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource?.tableView?(tableView, titleForFooterInSection: reversedSection(with: section))
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource?.tableView?(tableView, titleForHeaderInSection: reversedSection(with: section))
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate?.tableView?(tableView, viewForHeaderInSection: reversedSection(with: section))
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return delegate?.tableView?(tableView, viewForFooterInSection: reversedSection(with: section))
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didSelectRowAt: reversedIndexPath(with: indexPath))
    }

    // Editing
    
    // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSource?.tableView?(tableView, canEditRowAt: reversedIndexPath(with: indexPath)) ?? true
    }
    
    // Moving/reordering
    
    // Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return dataSource?.tableView?(tableView, canMoveRowAt: reversedIndexPath(with: indexPath)) ?? false
    }
    
    // Index
    
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSource?.sectionIndexTitles?(for: tableView)?.reversed()
    }
    
    // tell table which section corresponds to section title/index (e.g. "B",1))
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return dataSource?.tableView?(tableView, sectionForSectionIndexTitle: title, at: reversedSection(with: index)) ?? index
    }
    
    // Data manipulation - insert and delete support
    
    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataSource?.tableView?(tableView, commit: editingStyle, forRowAt: reversedIndexPath(with: indexPath))
    }
    
    // Data manipulation - reorder / moving support
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let source = reversedIndexPath(with: sourceIndexPath)
        let destination = reversedIndexPath(with: destinationIndexPath)
        dataSource?.tableView?(tableView, moveRowAt: source, to: destination)
    }
}
