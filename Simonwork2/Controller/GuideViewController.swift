//
//  GuideViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/04/02.
//

import UIKit

extension UIView {
    static func loadFromNib<T>() -> T? {
        let identifier = String(describing: T.self)
        let view = Bundle.main.loadNibNamed(identifier, owner: self, options: nil)?.first
        return view as? T
    }
}

class GuideViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        self.navigationItem.hidesBackButton = true
        
        addContentScrollView()
        setPageControl()
    }
    
    let FirstView : FirstView? = UIView.loadFromNib()
    let SecondView : SecondView? = UIView.loadFromNib()
    let ThirdView : ThirdView? = UIView.loadFromNib()
    
    private func addContentScrollView() {
        
        let viewNames = [FirstView, SecondView, ThirdView]
        for i in 0..<viewNames.count {
            //var uiView = views[i]
            let uiViewName = viewNames[i]
            let xPos = scrollView.frame.width * CGFloat(i)
            
            uiViewName?.frame = CGRect(
                x: xPos,
                y: 0,
                width: scrollView.bounds.width,
                height: scrollView.bounds.height)
            
            scrollView.contentSize.width = uiViewName!.frame.width * CGFloat(i + 1)
            scrollView.addSubview(uiViewName!)
        }
    }
        
    private func setPageControl() {
        pageControl.numberOfPages = 3
    }
    
    private func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
       performSegue(withIdentifier: "guideToConnect", sender: self)
    }
    
}
