/*********************************************
 
 MIT License
 
 Copyright (c) 2017 PagesJaunes SA
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 *********************************************/

import UIKit

open class MultipleTabsViewController: UIViewController {
  
  /// The height for the titles bar
  public var titlesHeight: CGFloat = 50
  
  /// The color for the bottom selected border of the tab
  public var titleBorderColor: UIColor = .black
  
  /// The height for the bottom selected border of the tab
  public var titleBorderHeight: CGFloat = 5
  
  /// The color for the title label when selected
  public var titleSelectedColor: UIColor = .black
  
  /// The color for the title label when unselected
  public var titleUnselectedColor: UIColor = .darkGray
  
  /// The font for the title label when selected
  public var titleSelectedFont: UIFont = .boldSystemFont(ofSize: 14)
  
  /// The font for the title label when unselected
  public var titleUnselectedFont: UIFont = .systemFont(ofSize: 14)
  
  /// The multiplier for the size of the bottom selected border compared of the width of the tab title
  public var borderWidthMultiplier: CGFloat = 0.8
  
  private var borderXConstraint: NSLayoutConstraint?
  
  public var dataSource: MultipleTabsViewControllerDataSource? {
    didSet {
      setup()
    }
  }

  public var delegate: MultipleTabsViewControllerDelegate?
  
  public func register<T>(type: T.Type, identifier: String) where T: UICollectionViewCell {
    collectionView.register(type, forCellWithReuseIdentifier: identifier)
  }
  
  public func register(nib: UINib?, identifier: String) {
    collectionView.register(nib, forCellWithReuseIdentifier: identifier)
  }
  
  public func dequeue(identifier: String, index: Int) -> UICollectionViewCell {
    
    let ip = IndexPath(item: index, section: 0)
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: ip)
  }
  
  public func reloadData() {
    collectionView.reloadData()
  }

  private var displayedTabIndexes = IndexSet()
  private var appearingTabIndexes = IndexSet()
  private var disappearingTabIndexes = IndexSet()

  public var selectedTabIndex: Int {
    get {
      return displayedTabIndexes.first ?? 0
    }
    set {
      setSelectedTabIndex(newValue, animated: false)
    }
  }

  public func setSelectedTabIndex(_ index: Int, animated: Bool) {
    collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
  }

  fileprivate func updateVisibleTabs(fullTabIndexes: IndexSet, partialTabIndexes: IndexSet) {
    let visibleTabIndexes = fullTabIndexes ∪ partialTabIndexes

    let disappearingDisplayedTabIndexes = displayedTabIndexes ∖ (displayedTabIndexes ∩ fullTabIndexes)
    let disappearingAppearingTabIndexes = appearingTabIndexes ∖ (appearingTabIndexes ∩ visibleTabIndexes)
    let allDisappearingTabIndexes = disappearingDisplayedTabIndexes ∪ disappearingAppearingTabIndexes
    let newDisappearingTabIndexes = allDisappearingTabIndexes ∖ disappearingTabIndexes
    newDisappearingTabIndexes.forEach { delegate?.multipleTabsViewController?(self, cellWillDisappearAtIndex: $0) }

    let allAppearingTabIndexes = visibleTabIndexes ∖ disappearingDisplayedTabIndexes
    let newAppearingTabIndexes = allAppearingTabIndexes ∖ appearingTabIndexes
    newAppearingTabIndexes.forEach { delegate?.multipleTabsViewController?(self, cellWillAppearAtIndex: $0) }

    let hiddenDisplayedTabIndexes = displayedTabIndexes ∖ (displayedTabIndexes ∩ visibleTabIndexes)
    let hiddenAppearingTabIndexes = appearingTabIndexes ∖ (appearingTabIndexes ∩ visibleTabIndexes)
    let allHiddenTabIndexes =

      /*
      .subtracting(fullTabIndexes)
      .subtracting(disappearingTabIndexes)
      .forEach {
        delegate?.multipleTabsViewController?(self, cellWillDisappearAtIndex: $0)
        appearingTabIndexes.remove($0)
        disappearingTabIndexes.insert($0)
    }

    // All the tabs that will appear for the first time
    fullTabIndexes
      .union(partialTabIndexes)
      .subtracting(displayedTabIndexes)
      .subtracting(appearingTabIndexes)
      .forEach {
        delegate?.multipleTabsViewController?(self, cellWillDisappearAtIndex: $0)
        appearingTabIndexes.remove($0)
        disappearingTabIndexes.insert($0)
    }

    // All the tabs that did disappear
    displayedTabIndexes
      .union(appearingTabIndexes)
      .subtracting(fullTabIndexes)
      .subtracting(disappearingTabIndexes)
      .forEach {
        delegate?.multipleTabsViewController?(self, cellWillDisappearAtIndex: $0)
        appearingTabIndexes.remove($0)
        disappearingTabIndexes.insert($0)
    }

    // All the tabs that did appear
    fullTabIndexes
      .subtracting(displayedTabIndexes)
      .forEach {
        delegate?.multipleTabsViewController?(self, cellDidAppearAtIndex: $0)
        appearingTabIndexes.remove($0)
        disappearingTabIndexes.insert($0)
    }
 */
  }

  private lazy var border: UIView = {
    
    let view = UIView()
    
    view.backgroundColor = self.titleBorderColor
    
    self.borderView.addSubview(view)
    
    return view
  }()
  
  private lazy var buttonsView: UIStackView = {
    
    let stackView = UIStackView()
    stackView.distribution = .fillEqually
    
    self.titlesView.addSubview(stackView)
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leadingAnchor.constraint(
      equalTo: self.titlesView.leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(
      equalTo: self.titlesView.trailingAnchor).isActive = true
    stackView.topAnchor.constraint(
      equalTo: self.titlesView.topAnchor).isActive = true
    stackView.bottomAnchor.constraint(
      equalTo: self.borderView.topAnchor).isActive = true
    
    return stackView
  }()
  
  private lazy var borderView: UIView = {
    
    let view = UIView()
    
    self.titlesView.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    view.leadingAnchor.constraint(
      equalTo: self.titlesView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(
      equalTo: self.titlesView.trailingAnchor).isActive = true
    view.bottomAnchor.constraint(
      equalTo: self.titlesView.bottomAnchor).isActive = true
    view.heightAnchor.constraint(
      equalToConstant: self.titleBorderHeight).isActive = true

    return view
  }()
  
  private lazy var titlesView: UIView = {
    
    let view = UIView()
    
    self.view.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    view.leadingAnchor.constraint(
      equalTo: self.view.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(
      equalTo: self.view.trailingAnchor).isActive = true
    view.topAnchor.constraint(
      equalTo: self.view.topAnchor).isActive = true
    view.heightAnchor.constraint(
      equalToConstant: self.titlesHeight).isActive = true

    return view
  }()

  private lazy var collectionView: UICollectionView = {
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    layout.scrollDirection = .horizontal
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    cv.dataSource = self
    cv.delegate = self
    
    cv.isPagingEnabled = true
    cv.bounces = false
    cv.showsHorizontalScrollIndicator = false
    
    self.view.addSubview(cv)
    
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.leadingAnchor.constraint(
      equalTo: self.view.leadingAnchor).isActive = true
    cv.trailingAnchor.constraint(
      equalTo: self.view.trailingAnchor).isActive = true
    cv.topAnchor.constraint(
      equalTo: self.titlesView.bottomAnchor).isActive = true
    cv.bottomAnchor.constraint(
      equalTo: self.view.bottomAnchor).isActive = true

    return cv
  }()
  
  private func setup() {
    
    reset()
    
    setupButtons()
    setupBorder()
    
    collectionView.cellForItem(at: IndexPath(item: 1, section: 0))
  }
  
  private func setupButtons() {
    
    if let nbItems = dataSource?.numberOfTabs(),
      nbItems > 0 {
      
      for index in 0 ..< nbItems {
        
        let button = UIButton(type: .custom)
        button.setTitle(dataSource?.title(forTabIndex: index), for: .normal)
        button.setTitleColor((index == 0) ? (titleSelectedColor) : (titleUnselectedColor), for: .normal)
        button.titleLabel?.font = (index == 0) ? (titleSelectedFont) : (titleUnselectedFont)
        
        buttonsView.addArrangedSubview(button)
        button.tag = index
        button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
      }
    }
  }
  
  private func setupBorder() {
    
    if let nbItems = dataSource?.numberOfTabs(),
      nbItems > 0 {
      
      border.translatesAutoresizingMaskIntoConstraints = false
      
      if let firstButton = buttonsView.subviews.first {
        self.borderXConstraint = border.centerXAnchor.constraint(
          equalTo: firstButton.centerXAnchor, constant: 0)
        self.borderXConstraint?.isActive = true
      }
      
      border.heightAnchor.constraint(
        equalTo: borderView.heightAnchor).isActive = true
      border.centerYAnchor.constraint(
        equalTo: borderView.centerYAnchor).isActive = true
      
      if let buttonView = buttonsView.subviews.first {
        border.widthAnchor.constraint(
          equalTo: buttonView.widthAnchor, multiplier: borderWidthMultiplier).isActive = true
      }
    }
  }
  
  @objc private func buttonPressed(_ button: UIButton) {
    
    let indexPath = IndexPath(item: button.tag, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
  }
  
  fileprivate func moved(toIndex index: Int) {
    
    buttonsView.subviews.forEach({
      if let button = $0 as? UIButton {
        button.setTitleColor((button.tag == index) ? (titleSelectedColor) : (titleUnselectedColor), for: .normal)
        button.titleLabel?.font = (button.tag == index) ? (titleSelectedFont) : (titleUnselectedFont)
      }
    })
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      
      guard let strongSelf = self else { return }
      
      self?.borderXConstraint?.isActive = false
      self?.borderXConstraint = self?.border.centerXAnchor.constraint(
        equalTo: strongSelf.buttonsView.subviews[index].centerXAnchor, constant: 0)
      self?.borderXConstraint?.isActive = true
      self?.view.layoutIfNeeded()
    }
  }
  
  private func reset() {
    
    border.removeConstraints(border.constraints)
    buttonsView.subviews.forEach({ $0.removeFromSuperview() })
    collectionView.reloadData()
  }
  
  override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil, completion: { [weak self] _ in
      
      self?.collectionView.collectionViewLayout.invalidateLayout()
      
      if self?.dataSource?.numberOfTabs() ?? 0 > 0 {
        let indexPath = IndexPath(item: 0, section: 0)
        self?.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
      }
    })
  }
}

extension MultipleTabsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource?.numberOfTabs() ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return dataSource?.cell(forTabIndex: indexPath.item) ?? UICollectionViewCell()
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
  
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    dataSource?.willDisplay?(cell: cell, forTabIndex: indexPath.item)
  }
  
  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    dataSource?.didEndDisplaying?(cell: cell, forTabIndex: indexPath.item)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.bounds.width > 0 else { return }
    let (i, f) = modf(scrollView.contentOffset.x / scrollView.bounds.width)
    let fullTabIndexes: IndexSet
    let partialTabIndexes: IndexSet
    if f == 0 {
      fullTabIndexes = IndexSet(integer: Int(i))
      partialTabIndexes = IndexSet()
    } else {
      fullTabIndexes = IndexSet()
      partialTabIndexes = IndexSet([Int(i), Int(i+1)])
    }
    updateVisibleTabs(fullTabIndexes: fullTabIndexes, partialTabIndexes: partialTabIndexes)

    let scrollViewFrameWidth = scrollView.frame.width > 0 ? scrollView.frame.width : 1

    moved(toIndex: Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / scrollViewFrameWidth))
  }

//  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//    guard scrollView.bounds.width > 0 else { return }
//    let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
//    setAppearedTabIndex(index)
//  }
//
//  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//    guard scrollView.bounds.width > 0 else { return }
//    let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
//    setAppearedTabIndex(index)
//  }

}

@objc public protocol MultipleTabsViewControllerDataSource {
  
  // The number of tabs you want
  @objc func numberOfTabs() -> Int
  
  /// The title for each tab
  @objc func title(forTabIndex index: Int) -> String
  
  /// Return the container cell you want for the tabIndex
  @objc func cell(forTabIndex index: Int) -> UICollectionViewCell
  
  /// Called just before cell will be displayed
  @objc optional func willDisplay(cell: UICollectionViewCell, forTabIndex index: Int)
  
  /// Called just after cell has been displayed
  @objc optional func didEndDisplaying(cell: UICollectionViewCell, forTabIndex index: Int)

}

@objc public protocol MultipleTabsViewControllerDelegate {

  @objc optional func multipleTabsViewController(_ multipleTabsViewController: MultipleTabsViewController, cellWillAppearAtIndex index: Int)
  @objc optional func multipleTabsViewController(_ multipleTabsViewController: MultipleTabsViewController, cellDidAppearAtIndex index: Int)
  @objc optional func multipleTabsViewController(_ multipleTabsViewController: MultipleTabsViewController, cellWillDisappearAtIndex index: Int)
  @objc optional func multipleTabsViewController(_ multipleTabsViewController: MultipleTabsViewController, cellDidDisappearAtIndex index: Int)

}

infix operator ∩
infix operator ∪
infix operator ∖

private extension SetAlgebra {

  static func ∩(lhs: Self, rhs: Self) -> Self {
    return lhs.intersection(rhs)
  }

  static func ∪(lhs: Self, rhs: Self) -> Self {
    return lhs.union(rhs)
  }

  static func ∖(lhs: Self, rhs: Self) -> Self {
    return lhs.subtracting(rhs)
  }

}
