//
//  BaseViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/04/19.
//

import Foundation
import GoogleMobileAds

public class BaseViewController: UIViewController {
    public lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        return banner
    }()
}

extension BaseViewController: GADBannerViewDelegate {
    func setupBannerViewToBottom(height: CGFloat = 50) {
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: height))
        bannerView = GADBannerView(adSize: adSize)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: height)
        ])

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    
    // MARK: - Delegate

    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }

    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    }

    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    }

    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    }

    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    }

    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    }
}
