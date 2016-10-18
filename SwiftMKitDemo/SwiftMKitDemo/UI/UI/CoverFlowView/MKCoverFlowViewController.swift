//
//  MKUICoverFlowViewController.swift
//  SwiftMKitDemo
//
//  Created by why on 16/5/31.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class MKCoverFlowViewController: BaseViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    
    @IBOutlet weak var questionCollectionView: UICollectionView!
    @IBOutlet weak var coverFlowLayout: CoverFlowLayout!
    @IBOutlet weak var selectBtnCollectionView: UICollectionView!
    @IBOutlet weak var btnsLayout: UICollectionViewFlowLayout!
    
    
    private struct InnerConst {
        static let QuestionCellID = "MKQuestionCollectionViewCell"
        static let SelectBtnCellID = "MKCoverFlowSelectBtnsCollectionViewCell"
        static let SelectBtnWidth: CGFloat = 35.0
        static let OriginalCollectionViewSize: CGSize = CGSizeMake(375.0, 558.0)
        static let CornerRaius: CGFloat = 2
        
    }
    
    var originalItemSize: CGSize = CGSizeZero
    var currentQuestionIndex: Int = 0
    var questions: [Question] = []
    var curQuestion : Question?
    
    var isReset: Bool = false
    var answeredCount: Int = 0

    var screenSize: CGSize {
        get {
            return UIScreen.mainScreen().bounds.size
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        originalItemSize = coverFlowLayout.itemSize
        for index in 1...10 {
            let question = Question()
            question.id = index.toString
            question.title = "\(index): 测试"
            question.options = []
            for j in 1...3 {
                let option = QuestionOption()
                option.optionId = j.toString
                option.optionCont = "\(j): 选项"
                question.options?.append(option)
            }
            questions.append(question)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        questionCollectionView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        questionCollectionView.hidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        coverFlowLayout.invalidateLayout()
        btnsLayout.invalidateLayout()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        coverFlowLayout.itemSize = CGSizeMake(questionCollectionView.bounds.size.width * (originalItemSize.width / InnerConst.OriginalCollectionViewSize.width), questionCollectionView.bounds.size.height * (originalItemSize.height / InnerConst.OriginalCollectionViewSize.height))
        
        questionCollectionView.setNeedsLayout()
        questionCollectionView.layoutIfNeeded()
        questionCollectionView.reloadData()
        selectBtnCollectionView.reloadData()
    }
    
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if scrollView == selectBtnCollectionView { return }
        //控制不能滚动
        let offsetx = scrollView.contentOffset.x - CGFloat(currentQuestionIndex) * screenSize.width
        if offsetx > 0 {
            if currentQuestionIndex >= answeredCount {
                scrollView.setContentOffset(CGPointMake(CGFloat(currentQuestionIndex) * screenSize.width, 0), animated: true)
            }
        }
    }
    
    //代码控制走这里
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView == selectBtnCollectionView { return }
        //计算当前位置
        currentCellIndex(scrollView.contentOffset.x)
    }
    //手动控制走这里
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == selectBtnCollectionView { return }
        //计算当前位置
        currentCellIndex(scrollView.contentOffset.x)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == questionCollectionView { return }
        if indexPath.row < answeredCount {
            questionCollectionView.setContentOffset(CGPointMake(CGFloat(indexPath.row) * screenSize.width, 0), animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == questionCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InnerConst.QuestionCellID, forIndexPath: indexPath) as! MKQuestionCollectionViewCell
            
            cell.layer.masksToBounds = false
            cell.layer.shadowOffset = CGSizeMake(0, 2)
            cell.layer.shadowRadius = InnerConst.CornerRaius
            let color = UIColor(hex6: 0x2868FF).colorWithAlphaComponent(0.1)
            cell.layer.shadowColor = color.CGColor
            cell.layer.shadowOpacity = 1.0
            cell.layer.cornerRadius = InnerConst.CornerRaius
            
            cell.questionModel = questions[indexPath.row]
            cell.userInteractionEnabled = currentQuestionIndex == indexPath.row
            cell.btnComplete.tag = indexPath.row
            cell.btnComplete.hidden = (indexPath.row != questions.count - 1)
            cell.lsCompleteBtnHeight.constant = cell.btnComplete.hidden ? 0: 40
            cell.lsCompleteBtnTop.constant = cell.btnComplete.hidden ? 0: 16
            cell.lsCompleteBtnBottom.constant = cell.btnComplete.hidden ? 10: 15
            cell.btnComplete.removeTarget(self, action: #selector(btnCompleteClick), forControlEvents: .TouchUpInside)
            if cell.btnComplete.hidden == false {
                cell.btnComplete.addTarget(self, action: #selector(btnCompleteClick), forControlEvents: .TouchUpInside)
            }
            cell.didSelectCellBlock = {
                [weak self] _ in
                self?.answeredCount = indexPath.row + 1
                self?.curQuestion = self?.questions[indexPath.row]
                self?.updateQuestions()
                self?.scrollNextQuestion()
            }
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InnerConst.SelectBtnCellID, forIndexPath: indexPath) as! MKCoverFlowSelectBtnsCollectionViewCell
            cell.lblNumber.text = "\(indexPath.row+1)"
            
            if indexPath.row == currentQuestionIndex {
                cell.type = .Selected
            }else if indexPath.row < answeredCount {
                cell.type = .Normal
            }else {
                cell.type = .Disabled
            }
            return cell
        }
    }
    
    private func scrollNextQuestion() {
        
        if currentQuestionIndex < self.questions.count-1 {
            currentQuestionIndex += 1
            questionCollectionView.setContentOffset(CGPointMake(CGFloat(currentQuestionIndex) * screenSize.width, 0), animated: true)
        }
    }
    
    func click_rightItem() {
        
        currentQuestionIndex = 0
        answeredCount = 0
        selectBtnCollectionView.setContentOffset(CGPointMake(0, 0), animated: true)
        questionCollectionView.setContentOffset(CGPointMake(0, 0), animated: true)
        reset()
        
    }
    
    func btnCompleteClick(sender: UIButton) {
        if sender.tag == questions.count - 1 {
            if answeredCount == questions.count {
                showTip("提交成功")
            } else {
                showTip("请答完题后再提交")
            }
        }
    }
    
    //计算位置
    private func currentCellIndex(OffsetX: CGFloat) {
        
        let index: Int = Int ((OffsetX + screenSize.width) / (20 + screenSize.width))
        if index != currentQuestionIndex {
            currentQuestionIndex = index
        }
        selectBtnCollectionView.reloadData()
        questionCollectionView.reloadData()
        setupNavigation()
        
        if currentQuestionIndex > answeredCount {
            questionCollectionView.setContentOffset(CGPointMake(CGFloat(answeredCount) * screenSize.width, 0), animated: true)
        }
        
        if (CGFloat(currentQuestionIndex+2) * InnerConst.SelectBtnWidth) > selectBtnCollectionView.bounds.size.width {
            if currentQuestionIndex < questions.count-1 {
                selectBtnCollectionView.setContentOffset(CGPointMake(CGFloat(currentQuestionIndex+2) * InnerConst.SelectBtnWidth - selectBtnCollectionView.bounds.size.width, 0), animated: true)
            }
        }else {
            if selectBtnCollectionView.contentOffset.x != 0 {
                if (CGFloat(currentQuestionIndex) * InnerConst.SelectBtnWidth) < selectBtnCollectionView.bounds.size.width {
                    selectBtnCollectionView.setContentOffset(CGPointMake(0, 0), animated: true)
                }
            }
        }
    }
    
    func updateQuestions() {
        
        //获取后面题的index
        let startIndex : Int = max(1, answeredCount)
        let endIndex : Int = max(1, (questions.count - 1))
        
        //清除后的面题
        if questions.count > endIndex && startIndex <= endIndex {
            
            //先清除后面题的已选
            for index in startIndex...endIndex {
                if let question : Question = questions[index]{
                    question.selectedOptionId = "-1"
                    question.selectedOption = question.options?.first
                }
            }
        }
    }
    
    func reset() {
        for question in questions {
            question.selectedOptionId = "-1"
            question.selectedOption = question.options?.first
        }
    }
}


class QuestionOption: NSObject {
    
    var optionId: String?
    var optionCont: String?
}

class Question: NSObject {
    
    var id: String?
    var title: String?
    var section: String?
    var options: [QuestionOption]?
    var selectedOptionId: String?
    var selectedOption: QuestionOption?
    
}
