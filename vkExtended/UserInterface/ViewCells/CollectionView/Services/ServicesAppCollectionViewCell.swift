//
//  ServicesAppCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 14.12.2020.
//

import UIKit
import IGListKit
import Material

enum ServiceCellType {
    case music
    case walletCourse
    case covid
    case weather
    case covid2
    
    static func getType(by appId: Int?, from title: String? = nil) -> Self {
        switch appId {
        case 7362610 where title == "Распространение COVID‑19":
            return .covid
        case 7362610 where title == nil:
            return .covid2
        case 7368392:
            return .walletCourse
        case 7293255:
            return .weather
        default:
            return .music
        }
    }
}

protocol ServicesAppHandler: class {
    func openMiniApp(from url: String)
}

class ServicesAppCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var appTitleLabel: UILabel!
    
    var isAnimated: Bool = false
    
    weak var miniAppDelegate: ServicesAppHandler?
    var miniAppUrl: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.isUserInteractionEnabled = true
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOpenMiniApp)))
        
        bgView.backgroundColor = .adaptableCard
        bgView.drawBorder(12, width: 0.4, color: .adaptableCard)
        appTitleLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        appTitleLabel.font = GoogleSansFont.medium(with: 13.5)
        appImageView.setCorners(radius: 4)
        appImageView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        appImageView.image = nil
        appTitleLabel.text = nil
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? SuperAppObjectViewModel else { return }
        configureCell(by: viewModel.type, from: viewModel)
        miniAppUrl = viewModel.miniApp?.webviewURL
    }
    
    @objc func onOpenMiniApp() {
        guard let url = miniAppUrl else { return }
        miniAppDelegate?.openMiniApp(from: url)
    }
}
extension ServicesAppCollectionViewCell {
    func configureCell(by type: ServiceCellType, from viewModel: SuperAppObjectViewModel) {
        if let stringURL = viewModel.miniApp?.icon75, let url = URL(string: stringURL) {
            appImageView.isHidden = false
            appImageView.kf.setImage(with: url)
        } else if let stringURL = viewModel.headerIcon?.first?.url, let url = URL(string: stringURL) {
            appImageView.isHidden = false
            appImageView.kf.setImage(with: url)
        } else if let stringURL = viewModel.coverPhotosURL?.first?.url, let url = URL(string: stringURL) {
            appImageView.isHidden = false
            appImageView.kf.setImage(with: url)
        } else if let stringURL = viewModel.images?.first?.url, let url = URL(string: stringURL) {
            appImageView.isHidden = false
            appImageView.kf.setImage(with: url)
        } else {
            appImageView.isHidden = true
        }
        appTitleLabel.text = viewModel.title?.uppercased()
        
        _ = bgView.subviews.map { if $0 != appImageView && $0 != appTitleLabel { $0.removeFromSuperview() } }
        switch type {
        case .music:
            configureMusicView(with: viewModel)
        case .walletCourse:
            break
        case .covid:
            configureCovidView(with: viewModel)
        case .weather:
            configureWeatherView(with: viewModel)
        case .covid2:
            configureCovid2View(with: viewModel)
        }
    }
    
    func configureCovidView(with viewModel: SuperAppObjectViewModel) {
        let levelStack = UIStackView(arrangedSubviews: [], axis: .horizontal, spacing: 2, alignment: .center, distribution: .equalCentering)
        bgView.addSubview(levelStack)
        levelStack.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 12)
        levelStack.autoPinEdge(.bottom, to: .bottom, of: bgView, withOffset: -10)
        levelStack.autoPinEdge(.trailing, to: .trailing, of: bgView, withOffset: -12)
        levelStack.autoSetDimensions(to: .custom(48, 32))
        
        _ = (viewModel.timelineDynamic ?? []).enumerated().map { index, timeline in
            let view = UIView()
            view.backgroundColor = index < (viewModel.timelineDynamic?.count ?? 0) - 1 ? UIColor.getAccentColor(fromType: .common).withAlphaComponent(0.75) : UIColor.extendedBackgroundRed.withAlphaComponent(0.75)
            view.drawBorder(1.75, width: 0.4, color: index < (viewModel.timelineDynamic?.count ?? 0) - 1 ? .getAccentColor(fromType: .common) : .extendedBackgroundRed)
            
            levelStack.addArrangedSubview(view)
            
            view.autoSetDimension(.width, toSize: 3.5, relation: .equal)
            view.autoPinEdge(.bottom, to: .bottom, of: levelStack)
            view.autoMatch(.height, to: .height, of: levelStack, withMultiplier: timeline.cgFloat)
        }

        let titleLabel = UILabel()
        titleLabel.textColor = .extendedBackgroundRed
        titleLabel.font = GoogleSansFont.medium(with: 14)
        bgView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 8)
        titleLabel.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 10)
        titleLabel.autoPinEdge(.trailing, to: .leading, of: levelStack, withOffset: -10)
        
        titleLabel.text = "+\(viewModel.totalIncrease ?? 0) \(viewModel.totalIncreaseLabel ?? "")"
        
        let subtitleLabel = UILabel()
        subtitleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        subtitleLabel.font = GoogleSansFont.medium(with: 14)
        bgView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 2)
        subtitleLabel.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 10)
        subtitleLabel.autoPinEdge(.trailing, to: .leading, of: levelStack, withOffset: -10)
        
        subtitleLabel.text = "+\(viewModel.localIncrease ?? 0) \(viewModel.localIncreaseLabel ?? "")"
    }
    
    func configureCovid2View(with viewModel: SuperAppObjectViewModel) {
        let titleLabel = UILabel()
        titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        titleLabel.font = GoogleSansFont.medium(with: 15)
        bgView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .top, of: bgView, withOffset: 12)
        titleLabel.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 42)
        titleLabel.autoPinEdge(.trailing, to: .trailing, of: bgView, withOffset: -10)
        
        titleLabel.text = viewModel.mainText
        
        let subtitleLabel = UILabel()
        subtitleLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        subtitleLabel.font = GoogleSansFont.regular(with: 14)
        subtitleLabel.numberOfLines = 0
        bgView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 2)
        subtitleLabel.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 42)
        subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: bgView, withOffset: -10)
        subtitleLabel.autoPinEdge(.bottom, to: .bottom, of: bgView, withOffset: -10)
        
        subtitleLabel.text = viewModel.additionalText
        subtitleLabel.sizeToFit()
    }
    
    func configureMusicView(with viewModel: SuperAppObjectViewModel) {
        let button = RaisedButton(title: "Играть")
        button.titleColor = .getAccentColor(fromType: .button)
        button.titleLabel?.font = GoogleSansFont.medium(with: 13)
        button.drawBorder(10, width: 1, color: .getAccentColor(fromType: .button), isOnlyTopCorners: false)
        button.contentEdgeInsets = .horizontal(12)
        bgView.addSubview(button)
        button.autoSetDimension(.height, toSize: 28)
        button.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 20)
        button.autoPinEdge(.trailing, to: .trailing, of: bgView, withOffset: -10)
        
        let titleLabel = UILabel()
        titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        titleLabel.font = GoogleSansFont.medium(with: 15)
        bgView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 12)
        titleLabel.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 10)
        titleLabel.autoPinEdge(.trailing, to: .leading, of: button, withOffset: -10)
        
        titleLabel.text = viewModel.mainText
        
        let subtitleLabel = UILabel()
        bgView.addSubview(subtitleLabel)
        subtitleLabel.textColor = .getAccentColor(fromType: .common)
        subtitleLabel.font = GoogleSansFont.medium(with: 14)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 2)
        subtitleLabel.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 10)
        subtitleLabel.autoPinEdge(.trailing, to: .leading, of: button, withOffset: -10)
        
        subtitleLabel.text = viewModel.additionalText
    }
    
    func configureWeatherView(with viewModel: SuperAppObjectViewModel) {
        let weatherImageView = UIImageView()
        bgView.addSubview(weatherImageView)
        weatherImageView.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 10)
        weatherImageView.autoPinEdge(.leading, to: .leading, of: bgView, withOffset: 10)
        weatherImageView.autoSetDimensions(to: .identity(50.5))
        
        weatherImageView.kf.setImage(with: URL(string: viewModel.images?[1].url))
        
        let tempLabel = UILabel()
        tempLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        tempLabel.font = GoogleSansFont.medium(with: 28)
        bgView.addSubview(tempLabel)
        tempLabel.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 16)
        tempLabel.autoPinEdge(.trailing, to: .trailing, of: bgView, withOffset: -10)
        tempLabel.autoSetDimension(.width, toSize: 60)
        tempLabel.textAlignment = .right
        
        tempLabel.text = viewModel.temperature
        
        let titleLabel = UILabel()
        titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        titleLabel.font = GoogleSansFont.medium(with: 15)
        bgView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: appTitleLabel, withOffset: 16)
        titleLabel.autoPinEdge(.leading, to: .trailing, of: weatherImageView, withOffset: 10)
        titleLabel.autoPinEdge(.trailing, to: .leading, of: tempLabel, withOffset: -10)
        
        titleLabel.text = viewModel.mainDescription
        
        let subtitleLabel = UILabel()
        bgView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 2)
        subtitleLabel.autoPinEdge(.leading, to: .trailing, of: weatherImageView, withOffset: 10)
        subtitleLabel.autoPinEdge(.trailing, to: .leading, of: tempLabel, withOffset: -10)
        
        subtitleLabel.attributedText = NSAttributedString(string: viewModel.shortDescription ?? "", attributes: [.font: GoogleSansFont.medium(with: 14), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .darkGray)]) + attributedSpace + NSAttributedString(string: viewModel.shortDescriptionAdditionalValue ?? "", attributes: [.font: GoogleSansFont.medium(with: 14), .foregroundColor: UIColor.getAccentColor(fromType: .common)])
    }
}
extension Date {
    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
   }

    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
}
