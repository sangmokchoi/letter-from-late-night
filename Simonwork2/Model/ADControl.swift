//
//  ADControl.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/04/19.
//

import GoogleMobileAds

extension UIViewController: GADBannerViewDelegate {
    func setupBannerViewToBottom(height: CGFloat = 60, adUnitID: String) {
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: height))
        let bannerView = GADBannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
