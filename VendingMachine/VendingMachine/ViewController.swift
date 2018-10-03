import UIKit

class ViewController: UIViewController {

    // MARK: - MODEL

    enum Product: Int {
        case cola = 1000
        case cider = 1100
        case fanta = 1200
        func name() -> String {
            switch self {
            case .cola: return "콜라"
            case .cider: return "사이다"
            case .fanta: return "환타"
            }
        }
    }

    enum Input {
        case moneyInput(Int)
        case productSelect(Product)
        case add(Product,Int)
        case reset
        case none
    }

    enum Output {
        case displayMoney(Int)
        case productOut(Product,Int)
        case shortMoneyError
        case runOutOfDrinkError
        case stockAdded(Product,Int)
        case change(Int)
    }

    struct State {
        let money: Int
        var stock: [Product:Int]
        static func initial() -> State {
            var P:[Product:Int] = [:]
            
            P[Product.cola] = 10
            P[Product.cider] = 10
            P[Product.fanta] = 10
            
            return State(money: 0,stock:P)
        }
    }

    // MARK: - UI

    @IBOutlet weak var displayMoney: UILabel!

    @IBOutlet weak var productOut: UIImageView!

    @IBOutlet weak var textInfo: UILabel!

    @IBAction func money100(_ sender: Any) {
        handleProcess("100")
    }

    @IBAction func money500(_ sender: Any) {
        handleProcess("500")
    }

    @IBAction func money1000(_ sender: Any) {
        handleProcess("1000")
    }

    @IBAction func selectCola(_ sender: Any) {
        handleProcess("cola")
    }

    @IBAction func selectCider(_ sender: Any) {
        handleProcess("cider")
    }

    @IBAction func selectFanta(_ sender: Any) {
        handleProcess("fanta")
    }

    @IBAction func reset(_ sender: Any) {
        handleProcess("reset")
    }
    @IBAction func addCola(_ sender: Any) {
        handleProcess("addCola")
    }
    @IBAction func addCider(_ sender: Any) {
        handleProcess("addCider")
    }
    @IBAction func addFanta(_ sender: Any) {
        handleProcess("addFanta")
    }
    // MARK: - LOGIC

    lazy var handleProcess = processHandler(State.initial())

    func processHandler(_ initState: State) -> (String) -> Void {
        var state = initState // memoization
        return { command in
            state = self.operation(self.uiInput(command), self.uiOutput)(state)
        }
    }

    func uiInput(_ command: String) -> () -> Input {
        return {
            switch command {
            case "100": return .moneyInput(100)
            case "500": return .moneyInput(500)
            case "1000": return .moneyInput(1000)
            case "cola": return .productSelect(.cola)
            case "cider": return .productSelect(.cider)
            case "fanta": return .productSelect(.fanta)
            case "reset": return .reset
            case "addCola": return .add(.cola, 1)
            case "addCider": return .add(.cider,1)
            case "addFanta": return .add(.fanta,1)
            default: return .none
            }
        }
    }

    func uiOutput(_ output: Output) -> Void {
        switch output {
        case .displayMoney(let m):
            displayMoney.text = "\(m)"

        case .productOut(let p,let n):
            switch p {
            case .cola:
                productOut.image = #imageLiteral(resourceName: "cola_l")
            case .cider:
                productOut.image = #imageLiteral(resourceName: "cider_l")
            case .fanta:
                productOut.image = #imageLiteral(resourceName: "fanta_l")
            }
            textInfo.text = "\(p.name())가 \(n)개 남았습니다."
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.productOut.image = nil
                self.textInfo.text = ""
            }

        case .shortMoneyError:
            textInfo.text = "잔액이 부족합니다."
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.textInfo.text = ""
            }

        case .change(let c):
            textInfo.text = "\(c)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.textInfo.text = ""
            }
        case .runOutOfDrinkError:
            textInfo.text = "해당 음료수가 다 떨어졌습니다."
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.textInfo.text = ""
            }
        case .stockAdded(let p,let n):
            textInfo.text = "\(p.name())가 \(n)개 추가되었습니다."
        }
    }

    func operation(_ inp: @escaping () -> Input, _ out: @escaping (Output) -> Void) -> (State) -> State {
        return { state in
            let input = inp()

            switch input {
            case .moneyInput(let m):
                let money = state.money + m
                out(.displayMoney(money))
                return State(money: money,stock:state.stock)

            case .productSelect(let p):
                if state.money < p.rawValue {
                    out(.shortMoneyError)
                    return state
                }
                if state.stock[p]! <= 0{
                    out(.runOutOfDrinkError)
                    return state
                }
                let money = state.money - p.rawValue
                let drinkStock = state.stock[p]! - 1
                var stock = state.stock
                stock[p] = drinkStock
                out(.productOut(p,drinkStock))
                out(.displayMoney(money))
                return State(money: money,stock: stock)

            case .reset:
                out(.change(state.money))
                out(.displayMoney(0))
                return State(money: 0,stock:state.stock)

            case .none:
                return state
            case .add(let p, let n):
                let drinkStock = state.stock[p]! + n
                var stock = state.stock
                stock[p] = drinkStock
                out(.stockAdded(p, n))
                return State(money:state.money,stock:stock)
                
            }
        }
    }

}

