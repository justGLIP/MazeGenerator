import UIKit
import PlaygroundSupport
import CoreGraphics

class MyViewController : UIViewController {
    let rows:CGFloat = 40 //количество строк в сетке
    let cols:CGFloat = 40 //количество столбцов в сетке
    var grid:[cell] = [] //сетка клеток
    var temp = 0
    var stack:[cell] = []
    var unvisitedNeighbours = false
    
    class cell {
        var walls = [true, true, true, true] // стены = [верхняя, правая, нижняя, левая]
        var start: CGPoint //координаты верхнего левого угла клетки
        var isVisited = false
        var row, col: Int
        init(start: CGPoint, row: Int, col: Int){
            self.start = start
            self.row = row
            self.col = col
        }
    }
    
    
    
    override func loadView() {
        var currentCell: cell
        var nextCell = cell(start: CGPoint.zero, row: 0, col: 0)
        var neighbours: [cell] = []
        // Поле для рисования
        let size = CGSize(width: 400, height: 400) //размер холста
        let cellSize = CGSize(width: size.width/rows, height: size.height/cols) //размер клетки
        let view = UIView()
        view.bounds.size = size
        let imageView = UIImageView(image: nil)
        imageView.frame = CGRect(origin: .zero, size: size)
        view.addSubview(imageView)
        self.view = view
        
        // заполняем массив клетками
        for i in 0...Int(rows)-1 {
            for j in 0...Int(cols)-1{
                grid.append(cell(start: CGPoint(x: CGFloat(j)*cellSize.width, y: CGFloat(i)*cellSize.height), row: i, col: j))
            }
        }
        
        
        
        //Шаг 1
        currentCell = grid[0]
        currentCell.isVisited = true
        stack.append(currentCell)
        
        //Шаг 2
        _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
        if !stack.isEmpty {
            //2.1
            currentCell = stack.removeLast()
            //2.2
            neighbours = checkNeighbours(to: currentCell)
            if !neighbours.isEmpty {
                //2.2.1
                stack.append(currentCell)
                //2.2.2
                nextCell = neighbours[Int.random(in: 0...neighbours.count-1)]
                //2.2.3
                removeWalls(between: currentCell, and: nextCell)
                //2.2.4
                nextCell.isVisited = true
                currentCell = nextCell
                stack.append(nextCell)
            }
            // print(stack.count   )
            drawGrid(grid: grid)
        } else { timer.invalidate() }
        }
        
        // MARK: рисуем поле с клетками
        func drawGrid(grid: [cell]){
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.width, height: size.height))
            
            let img = renderer.image { context in
                context.cgContext.setLineWidth(4)
                context.cgContext.setStrokeColor(UIColor.black.cgColor)
                
                for i in grid.indices {
                    
                    if grid[i].isVisited {
                        context.cgContext.addRect(CGRect(origin: grid[i].start, size: cellSize))
                        context.cgContext.setFillColor(UIColor.green.cgColor)
                        context.cgContext.fillPath()
                        
                        context.cgContext.addRect(CGRect(origin: currentCell.start, size: cellSize))
                        context.cgContext.setFillColor(UIColor.purple.cgColor)
                        context.cgContext.fillPath()
                        
                    }
                    
                    context.cgContext.move(to: grid[i].start)
                    
                    //верхняя стенка
                    if grid[i].walls[0] {
                        context.cgContext.addLine(to: CGPoint(x: grid[i].start.x + cellSize.width, y: grid[i].start.y))
                    } else {
                        context.cgContext.move(to: CGPoint(x: grid[i].start.x + cellSize.width, y: grid[i].start.y))
                    }
                    
                    //правая стенка
                    if grid[i].walls[1] {
                        context.cgContext.addLine(to: CGPoint(x: grid[i].start.x + cellSize.width, y: grid[i].start.y + cellSize.height))
                    } else {
                        context.cgContext.move(to: CGPoint(x: grid[i].start.x + cellSize.width, y: grid[i].start.y + cellSize.height))
                    }
                    
                    //нижняя стенка
                    if grid[i].walls[2] {
                        context.cgContext.addLine(to: CGPoint(x: grid[i].start.x, y: grid[i].start.y + cellSize.height))
                    } else {
                        context.cgContext.move(to: CGPoint(x: grid[i].start.x, y: grid[i].start.y + cellSize.height))
                    }
                    
                    //левая стенка
                    if grid[i].walls[3] {
                        context.cgContext.addLine(to: CGPoint(x: grid[i].start.x, y: grid[i].start.y))
                    } else {
                        context.cgContext.move(to: CGPoint(x: grid[i].start.x, y: grid[i].start.y))
                    }
                    
                    context.cgContext.drawPath(using: .stroke)
                }
                
                
            }
            imageView.image = img
        }
        
        func checkNeighbours(to me: cell) -> [cell] {
            
            var neighbours: [cell] = []
            var top = cell(start: CGPoint.zero, row: 0, col: 0)
            var right = cell(start: CGPoint.zero, row: 0, col: 0)
            var bottom = cell(start: CGPoint.zero, row: 0, col: 0)
            var left = cell(start: CGPoint.zero, row: 0, col: 0)
            
            top.isVisited = true
            right.isVisited = true
            bottom.isVisited = true
            left.isVisited = true
            
            let topIndex = me.col + (me.row-1) * Int(cols)
            let rightIndex = me.col+1 + me.row * Int(cols)
            let bottomIndex = me.col + (me.row+1) * Int(cols)
            let leftIndex = me.col-1 + me.row * Int(cols)
            if me.row > 0 { top = grid[topIndex] }
            if me.col < Int(cols)-1 { right = grid[rightIndex] }
            if me.row < Int(rows)-1 { bottom = grid[bottomIndex] }
            if me.col > 0 { left = grid[leftIndex] }
            
            if !top.isVisited { neighbours.append(top) }
            if !right.isVisited { neighbours.append(right) }
            if !bottom.isVisited { neighbours.append(bottom) }
            if !left.isVisited { neighbours.append(left) }
            return neighbours
        }
        
        func removeWalls (between a:cell, and b:cell) {
            //сосед сверху
            if (a.row - b.row) == 1 {
                a.walls[0] = false
                b.walls[2] = false
            }
            //сосед справа
            if (a.col - b.col) == -1 {
                a.walls[1] = false
                b.walls[3] = false
            }
            //сосед снизу
            if (a.row - b.row) == -1 {
                a.walls[2] = false
                b.walls[0] = false
            }
            //сосед слева
            if (a.col - b.col) == 1 {
                a.walls[3] = false
                b.walls[1] = false
            }
        }
        
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
