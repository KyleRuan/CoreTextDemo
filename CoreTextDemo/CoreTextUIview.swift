//
//  CoreTextUIview.swift
//  CoreTextDemo
//
//  Created by Jason on 15/10/23.
//  Copyright © 2015年 KYLERUAN. All rights reserved.
//
//文章地址：http://www.jianshu.com/p/fa900c396406
import UIKit
import CoreText
class CoreTextUIview: UIView{
    
    
    override func drawRect(rect: CGRect) {
        
        // 步骤1：得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
        let  context  = UIGraphicsGetCurrentContext()
        // 步骤2：翻转当前的坐标系
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty:self.bounds.height)
        CGContextConcatCTM(context, transform)
        //步骤3：创建需要绘制的文字及属性
        let str = NSMutableAttributedString(string: "在足球界，年龄是个十分奇怪的东西，你要么太年轻，要么太老；要么经验不足，要么老得什么都做不了；要么乃义务，要么就是应该做地更好。不管是成名太早，还是原地踏步太久，都会给一位球运动员造成很坏的影响。年轻人总是会受到最多的抨击，或者被球迷、主教练或者媒体榨干所有价值。最近的贝拉希诺就是一个很好的例子。这位前锋在转会窗期间犯下了一些低级的错误，每个人都对这位现年22岁的前锋有点看法，导致他从顶梁柱变成了普通的一根桩子")
        //以下为可选的部分
        //设置文字颜色
        str.addAttribute(kCTForegroundColorAttributeName as String, value:UIColor.redColor() , range: NSMakeRange(0,1))
        // 设置文字包括字体大小和字体
        let fontRef = CTFontCreateWithName("ArialMT", 20, nil)
        str.addAttribute(kCTFontAttributeName as String, value: fontRef, range:NSMakeRange(0, 1))
        
        //设置行间距
        var  lineSpacing:CGFloat = 5;
        let settings = [CTParagraphStyleSetting(spec: .LineSpacingAdjustment, valueSize: sizeof(CGFloat), value:&lineSpacing),CTParagraphStyleSetting(spec: .MaximumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing),CTParagraphStyleSetting(spec: .MinimumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing)]
        
        let theParagraphRef = CTParagraphStyleCreate(settings, 3)
        
        str.addAttribute(kCTParagraphStyleAttributeName as String, value: theParagraphRef, range: NSMakeRange(0,str.length))
        
        
        //步骤4：创建绘制区域 ，就是在self.bounds中以何种方式展示，
        let path = CGPathCreateMutable()
        //不同的绘制方法
//        CGPathAddRect(path, nil, self.bounds)
          CGPathAddEllipseInRect(path, nil, self.bounds);
        
        
        //(可选)步骤7：绘制图片，
        //7.1为图片设置CTRunDelegate,delegate决定留给图片的空间大小
        var imageName = "read"
        var  imageCallback =  CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (refCon) -> Void in
            NSLog("RunDelegate dealloc")
            }, getAscent: { ( refCon) -> CGFloat in
                let imageName = "read"
                refCon.initialize()
                let image = UIImage(named: imageName)
                return image!.size.height
            }, getDescent: { (refCon) -> CGFloat in
                return 0
            }) { (refCon) -> CGFloat in
                
                let imageName = String("read")
                let image = UIImage(named: imageName)
                return image!.size.width
        }
        
        
        // 7.2设置CTRun的代理
        let runDelegate = CTRunDelegateCreate(&imageCallback,&imageName)
        let imageAttributedString = NSMutableAttributedString(string: " ");//空格用于给图片留位置
        imageAttributedString.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSMakeRange(0, 1))
        imageAttributedString.addAttribute("imageName", value: imageName, range: NSMakeRange(0, 1))//添加属性，在CTRun中可以识别出这个字符是图片
        str.insertAttributedString(imageAttributedString, atIndex: 2)
        
        
        //步骤5：根据AttributedString生成CTFramesetterRef
        let frameSetter = CTFramesetterCreateWithAttributedString(str)
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0,str.length), path, nil)
        
        //步骤6：绘制除图片以外的部分
        CTFrameDraw(ctFrame, context!)
        
        
        //7.3处理绘制图片逻辑
        let lines = CTFrameGetLines(ctFrame) as NSArray //存取frame中的ctlines
        
        let nsLinesArray: NSArray = CTFrameGetLines(ctFrame) // Use NSArray to bridge to Array
        let ctLinesArray = nsLinesArray as Array
        var originsArray = [CGPoint](count:ctLinesArray.count, repeatedValue: CGPointZero)
        let range: CFRange = CFRangeMake(0, 0)
        CTFrameGetLineOrigins(ctFrame, range,&originsArray)
        
        //7.2把ctFrame里每一行的初始坐标写到数组里
        //        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &origunsArray);
        
        // 7.3遍历CTRun找出图片所在的CTRun并进行绘制,每一行可能有多个
        for i in 0..<lines.count{
            //遍历每一行CTLine
            let line = lines[i]
            var lineAscent = CGFloat()
            var lineDescent = CGFloat()
            var lineLeading = CGFloat()
            
            
            CTLineGetTypographicBounds(line as! CTLineRef, &lineAscent, &lineDescent, &lineLeading)
            //
            let runs = CTLineGetGlyphRuns(line as! CTLine) as NSArray
            for j in 0..<runs.count{
                // 遍历每一个CTRun
                var  runAscent = CGFloat()
                var  runDescent = CGFloat()
                let  lineOrigin = originsArray[i]// 获取该行的初始坐标
                
                let run = runs[j] // 获取当前的CTRun
                let attributes = CTRunGetAttributes(run as! CTRun) as NSDictionary
                let width =  CGFloat( CTRunGetTypographicBounds(run as! CTRun, CFRangeMake(0,0), &runAscent, &runDescent, nil))
                //                runRect.size.width = CGFloat( CTRunGetTypographicBounds(run as! CTRun, CFRangeMake(0,0), &runAscent, &runDescent, nil))
                // 这一段可参考Nimbus的NIAttributedLabel
                let  runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line as! CTLine, CTRunGetStringRange(run as! CTRun).location, nil), lineOrigin.y - runDescent, width, runAscent + runDescent)
                let  imageNames = attributes.objectForKey("imageName")
                if imageNames is NSString {
                    let image = UIImage(named: imageName as String)
                    let  imageDrawRect = CGRectMake(runRect.origin.x, lineOrigin.y, (image?.size.width)!, (image?.size.height)!)
                    print(imageDrawRect)
                    
                    CGContextDrawImage(context, imageDrawRect, image!.CGImage)
                    
                }
                
                
            }
            
        }
        
        
    }
    
    
}