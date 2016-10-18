//
//  QuestionCollectionViewCellTableViewCell.swift
//  SwiftMKitDemo
//
//  Created by Mao on 18/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKQuestionCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var lsCompleteBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var lsCompleteBtnTop: NSLayoutConstraint!
    @IBOutlet weak var lsCompleteBtnBottom: NSLayoutConstraint!
    
    var didSelectCellBlock: ((String?) -> Void)?
    
    var optionsArray: [QuestionOption] = [QuestionOption]()
    
    var questionModel: Question? {
        didSet {
            optionsArray = questionModel?.options ?? []
            listView.reloadData()
        }
    }
    
    var selectedOptionId: String? {
        get {
            return questionModel?.selectedOptionId
        }
        set {
            questionModel?.selectedOptionId = newValue
        }
    }
    
    struct InnerConst {
        static let CellIdentifier = "MKQuestionOptionsTableViewCell"
        static let QuestionFontOfSize: CGFloat = 15.0
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var cellHeight: CGFloat = 0.0
        if optionsArray.count > 0 {
            if let optionModel:QuestionOption = optionsArray[indexPath.row] {
                cellHeight = cellHeightWithText(optionModel.optionCont ?? "")
                cellHeight = CGFloat(Int(cellHeight))
            }
        }
        return cellHeight < 46.0 ? 46.0 : cellHeight
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if optionsArray.count > 0 {
            let optionModel = optionsArray[indexPath.row]
            cell?.textLabel?.text = optionModel.optionCont ?? ""
            cell?.textLabel?.textColor = UIColor(hex6: 0x969CA4)
            if (selectedOptionId == optionModel.optionId) {
                //tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                cell?.textLabel?.textColor = UIColor(hex6: 0xFD734C)
            }
        }
        return cell!
        
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let height = headerViewHeightWithText(questionModel?.title ?? "")
        let view = UIView(frame:CGRectMake(0, 0, tableView.size.width, height))
        let lblQuestion = UILabel(frame:CGRectMake(10.0, 30.0, tableView.size.width - 20.0, height - 45.0))
        lblQuestion.numberOfLines = 0
        view.backgroundColor = UIColor.clearColor()
        lblQuestion.backgroundColor = UIColor.clearColor()
        let font = UIFont.systemFontOfSize(InnerConst.QuestionFontOfSize)
        lblQuestion.font = font
        lblQuestion.textColor = UIColor(hex6: 0x53606E)
        lblQuestion.text = "\(questionModel?.title ?? "")"
        view.addSubview(lblQuestion)
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeightWithText(questionModel?.title ?? "")
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame:CGRectMake(0, 0, tableView.size.width, 1.0))
        view.backgroundColor = UIColor(hex6: 0xF3F6FC)
        return view
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    private func headerViewHeightWithText(text:String) -> CGFloat {
        let font = UIFont.systemFontOfSize(InnerConst.QuestionFontOfSize)
        let labelW: CGFloat = listView.size.width - 20.0
        let rect: CGRect = text.boundingRectWithSize(CGSizeMake(labelW, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading] , attributes: [NSFontAttributeName: font] , context: nil)
        return rect.height+50.0
    }
    
    private func cellHeightWithText(text:String) -> CGFloat {
        var font = UIFont.systemFontOfSize(14)
        if #available(iOS 8.2, *) {
            font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        }
        let labelW: CGFloat = listView.size.width - 31.0
        let rect: CGRect = text.boundingRectWithSize(CGSizeMake(labelW, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading] , attributes: [NSFontAttributeName:font] , context: nil)
        return rect.height + 30.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let handler = didSelectCellBlock {
            let optionModel = optionsArray[indexPath.row]
            questionModel?.selectedOption = optionModel
            selectedOptionId = optionModel.optionId
            handler(selectedOptionId)
            tableView.reloadData()
        }
    }

}
