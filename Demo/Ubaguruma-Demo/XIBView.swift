//
//  XIBView.swift
//  Ubaguruma-Demo
//
//  Created by Daichi Nakajima on 2019/06/02.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit

class XIBView: UIView {
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = nil
        clearsContextBeforeDrawing = false
        layer.removeFromSuperlayer()
        
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    

}

