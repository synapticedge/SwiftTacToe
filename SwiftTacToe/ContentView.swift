import SwiftUI
enum SquareType{ case x; case o; case empty; case draw }
struct ContentView: View {
    @State var status = SquareType.empty
    @State var squares = Array( repeating: SquareType.empty, count: 9){
        didSet{
            status = AI.checkForWin(self.squares)
        }
    }
    var body: some View {
        
        VStack{
            ZStack{
                Text("X Wins!").opacity(status == SquareType.x ? 1.0 : 0.0)
                Text("O Wins!").opacity(status == SquareType.o ? 1.0 : 0.0)
                Text("Draw!").opacity(status == SquareType.draw ? 1.0 : 0.0)
            }
            VStack{
                HStack{
                    Square(squareNum: 0, contentView: self)
                    Square(squareNum: 1, contentView: self)
                    Square(squareNum: 2, contentView: self)
                }
                HStack{
                    Square(squareNum: 3, contentView: self)
                    Square(squareNum: 4, contentView: self)
                    Square(squareNum: 5, contentView: self)
                    
                }
                HStack{
                    Square(squareNum: 6, contentView: self)
                    Square(squareNum: 7, contentView: self)
                    Square(squareNum: 8, contentView: self)
                }
            }.disabled(self.status != SquareType.empty)
            
        }.padding()
    }
}
class AI {
    static func checkRow(_ one :SquareType,_ two: SquareType,_ three:SquareType) -> SquareType{
        if one == two && two == three {return one}
        else {return SquareType.empty}
    }
    static func checkForWin(_ board: [SquareType])->SquareType {
        if AI.checkRow(board[0],board[1],board[2]) == SquareType.x
            || AI.checkRow(board[3],board[4],board[5]) == SquareType.x
            || AI.checkRow(board[6],board[7],board[8]) == SquareType.x
            || AI.checkRow(board[0],board[4],board[8]) == SquareType.x
            || AI.checkRow(board[2],board[4],board[6]) == SquareType.x{
            return SquareType.x
        }
        if AI.checkRow(board[0],board[1],board[2]) == SquareType.o
            || AI.checkRow(board[3],board[4],board[5]) == SquareType.o
            || AI.checkRow(board[6],board[7],board[8]) == SquareType.o
            || AI.checkRow(board[0],board[4],board[8]) == SquareType.o
            || AI.checkRow(board[2],board[4],board[6]) == SquareType.o{
            return SquareType.o
        }
        for z in 0...8{
            if board[z] == .empty {  return .empty  }
        }
        return SquareType.draw
    }
    static func modifyTacToe(_ board: [SquareType])->[SquareType]{
        var retBoard = board
        for x in (0...8){
            if board[x] == SquareType.empty{
                retBoard[x] = SquareType.o
                return retBoard
            }
        }
        return retBoard
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct Square: View {
    var squareNum: Int!
    var contentView: ContentView!
    var body: some View {
        ZStack {
            Button(action: {
                if self.contentView.squares[self.squareNum] == SquareType.empty{
                    self.contentView.squares[self.squareNum] = SquareType.x
                }
                self.contentView.squares = AI.modifyTacToe(self.contentView.squares)
            }) {
                Rectangle().frame(width: 100, height: 100, alignment: .center)
            }
            .buttonStyle(PlainButtonStyle())
            Text("O").opacity(self.contentView.squares[self.squareNum] == SquareType.o ? 1.0 : 0.0).font(.largeTitle).foregroundColor(.red)
            Text("X").opacity(self.contentView.squares[self.squareNum] == SquareType.x ? 1.0 : 0.0).font(.largeTitle).foregroundColor(.blue)
        }
    }
}

