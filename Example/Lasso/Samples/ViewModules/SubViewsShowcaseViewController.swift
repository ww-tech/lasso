//
// ==----------------------------------------------------------------------== //
//
//  SubViewsShowcaseViewController.swift
//
//  Created by Steven Grosmark on 5/29/23
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2023 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import UIKit
import Lasso

// MARK: - ViewModules

final class SubViewsShowcaseViewController: UIViewController, LassoView {
    
    let store: SubViewsShowcase.ViewStore
    
    private let descriptionLabel = UILabel()
    
    init(store: SubViewsShowcase.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.layout.fill(.safeArea, except: .bottom, inset: 20)
        
        descriptionLabel.text = "Demonstrates using ViewModules.\nEach component on this screen uses a ViewModule to provide precisely scoped access to the state / actions that are relevant to it."
        descriptionLabel.numberOfLines = 0
        stack.addArrangedSubview(descriptionLabel)
        
        let slider1 = VolumeSlider(store: store.asReadWriteVolumeViewStore())
        stack.addArrangedSubview(slider1)
        
        let volumes = UIStackView()
        volumes.axis = .horizontal
        volumes.spacing = 10
        volumes.alignment = .fill
        volumes.distribution = .fillEqually
        volumes.addArrangedSubviews(
            VolumeBar(store: store.asReadOnlyVolumeViewStore()),
            VolumeBar(store: store.asReadOnlyVolumeViewStore()),
            VolumeBar(store: store.asReadOnlyVolumeViewStore()),
            VolumeBar(store: store.asReadOnlyVolumeViewStore()),
            VolumeBar(store: store.asReadOnlyVolumeViewStore())
        )
        volumes.layout.height(100)
        stack.addArrangedSubview(volumes)
        
        let slider2 = VolumeSlider(store: store.asReadWriteVolumeViewStore())
        stack.addArrangedSubview(slider2)
        
        let button = MuteSwitch(store: store.asToggleableMuteViewStore())
        stack.addArrangedSubview(button)
    }
}

/// Volume ----O---------
final class VolumeSlider: UIView, LassoView {
    
    let store: ReadWriteVolume.ViewStore
    
    private let label = UILabel()
    private let slider = UISlider()
    
    init(store: ReadWriteVolume.ViewStore) {
        self.store = store
        super.init(frame: .zero)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        
        label.text = "Volume"
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        addSubview(stack)
        stack.addArrangedSubviews(label, slider)
        stack.layout.fill(.superview)
        
        store.observeState(\.volume) { [weak self] volume in
            self?.slider.setValue(Float(volume), animated: true)
        }
        slider.bindValueChange(to: store) { newValue in
            .didAdjustVolume(Double(newValue))
        }
    }
    
    required init?(coder: NSCoder) { nil }
}

/// Vertical volume indicator.
final class VolumeBar: UIView, LassoView {
    
    let store: ReadOnlyVolume.ViewStore
    
    private let volumeView = UIView()
    private var heightConstraint: NSLayoutConstraint?
    
    init(store: ReadOnlyVolume.ViewStore) {
        self.store = store
        super.init(frame: .zero)
        
        addSubview(volumeView)
        volumeView.layout.fill(.superview, except: .top)
        
        backgroundColor = .lightGray.withAlphaComponent(0.25)
        
        volumeView.backgroundColor = UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 0.5)
        
        store.observeState(\.volume) { [weak self] volume in
            guard let self = self else { return }
            self.heightConstraint?.isActive = false
            self.heightConstraint = self.volumeView.layout
                .height(to: self, multiplier: volume).constraints().first
        }
    }
    
    required init?(coder: NSCoder) { nil }
}

final class MuteSwitch: UIView, LassoView {
    
    let store: ToggleableMute.ViewStore
    
    private let label = UILabel()
    private let muteSwitch = UISwitch()
    
    init(store: ToggleableMute.ViewStore) {
        self.store = store
        super.init(frame: .zero)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        
        label.text = "Mute"
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        addSubview(stack)
        stack.addArrangedSubviews(label, muteSwitch)
        stack.layout.fill(.superview, except: .right)
        
        store.observeState(\.muted) { [weak self] muted in
            self?.muteSwitch.setOn(muted, animated: true)
        }
        muteSwitch.bindValueChange(to: store) { isOn in
            .didTapMute(isOn)
        }
    }
    
    required init?(coder: NSCoder) { nil }
}
