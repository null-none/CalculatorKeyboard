import UIKit

enum Operation {
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
}

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var display: UILabel!
    var calculatorView: UIView!
    var shouldClearDisplayBeforeInserting = true
    
    var internalMemory = 0.0
    var operationPress = Operation.None
    var shouldCompute = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        clearDisplay()
        
    }
    
    func loadInterface() {
        let calculatorNib = UINib(nibName: "Calculator", bundle: nil)
        calculatorView = calculatorNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        view.addSubview(calculatorView)
        
        view.backgroundColor = calculatorView.backgroundColor
        
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
    }
    
    @IBAction func clearDisplay() {
        display.text = "0"
        internalMemory = 0
        operationPress = Operation.Addition
        shouldClearDisplayBeforeInserting = true
    }
    
    
    @IBAction func didTapNumber(number: UIButton) {
        if shouldClearDisplayBeforeInserting {
            display.text = ""
            shouldClearDisplayBeforeInserting = false
        }
        
        shouldCompute = true
        
        if let numberAsString = number.titleLabel?.text {
            let numberAsNSString = numberAsString as NSString
            if let oldDisplay = display?.text! {
                display.text = "\(oldDisplay)\(numberAsNSString.intValue)"
            } else {
                display.text = "\(numberAsNSString.intValue)"
            }
        }
    }

    @IBAction func didTapDot() {
        if let input = display?.text {
            var hasDot = false
            for ch in input.unicodeScalars {
                if ch == "." {
                    hasDot = true
                    break
                }
            }
            if hasDot == false {
                display.text = "\(input)."
            }
        }
    }

    @IBAction func didTapInsert() {
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = display?.text as String? {
            proxy.insertText(input)
        }
    }

    @IBAction func didTapOperation(operation: UIButton) {
        if shouldCompute {
            computeLastOperation()
        }
        
        if let op = operation.titleLabel?.text {
            switch op {
            case "+":
                operationPress = Operation.Addition
            case "-":
                operationPress = Operation.Subtraction
            case "*":
                operationPress = Operation.Multiplication
            case "/":
                operationPress = Operation.Division
            default:
                operationPress = Operation.None
            }
        }
    }
    
    @IBAction func computeLastOperation() {
        // remember not to compute if another operation is pressed without inputing another number first
        shouldCompute = false
        
        if let input = display?.text {
            let inputAsDouble = (input as NSString).doubleValue
            var result = 0.0
            
            // apply the operation
            switch operationPress {
            case .Addition:
                result = internalMemory + inputAsDouble
            case .Subtraction:
                result = internalMemory - inputAsDouble
            case .Multiplication:
                result = internalMemory * inputAsDouble
            case .Division:
                result = internalMemory / inputAsDouble
            default:
                result = 0.0
            }
            
            operationPress = Operation.None
            
            var output = "\(result)"
            
            if output.hasSuffix(".0") {
                output = "\(Int(result))"
            }
            
            var components = output.componentsSeparatedByString(".")
            if components.count >= 2 {
                let beforePoint = components[0]
                var afterPoint = components[1]
                if afterPoint.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 5 {
                    let index: String.Index = afterPoint.startIndex.advancedBy(5)
                    afterPoint = afterPoint.substringToIndex(index)
                }
                output = beforePoint + "." + afterPoint
            }
            
            display.text = output
            internalMemory = result
            shouldClearDisplayBeforeInserting = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func textWillChange(textInput: UITextInput?) {
    }

    override func textDidChange(textInput: UITextInput?) {
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

}

class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

class RoundLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
