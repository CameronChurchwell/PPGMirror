//
//  Posteriorgram.swift
//  PPGMirror
//
//  Created by Steam Train on 3/11/24.
//

import Foundation
import SwiftUI
import UIKit

class ColorGridModel: ObservableObject {
    @Published var colors: [[Color]]
    
    init(width: Int, height: Int, initial_color: Color) {
        self.colors = Array(repeating: Array(repeating: initial_color, count: width), count: height)
    }
}

class CGFloatModel: ObservableObject {
    @Published var value: CGFloat = 0.0
}

struct CellView: View {
    var color: Color
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
    }
}

func color_to_vec(color: UIColor) -> [CGFloat] {
    var color_vec: [CGFloat] = [0.0, 0.0, 0.0, 0.0]
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    color_vec[0] = red
    color_vec[1] = green
    color_vec[2] = blue
    color_vec[3] = alpha
    return color_vec
}

func vec_to_color(vec: [CGFloat]) -> Color {
    assert(vec.count == 4)
    let color: UIColor = UIColor(red: vec[0], green: vec[1], blue: vec[2], alpha: vec[3])
    return Color(color)
}

func linear_interpolate_colors(first: UIColor, second: UIColor, value: Float) -> Color {
    assert(0 <= value && value <= 1)
    
    let vec0 = color_to_vec(color: first)
    let vec1 = color_to_vec(color: second)
    
    let factor: CGFloat = CGFloat(value)
    let recip: CGFloat = CGFloat(1.0 - value)
    
    let vec3: [CGFloat] = [
        factor*vec0[0] + recip*vec1[0],
        factor*vec0[1] + recip*vec1[1],
        factor*vec0[2] + recip*vec1[2],
        factor*vec0[3] + recip*vec1[3]
    ]
    
    let new_color: Color = Color(UIColor(vec_to_color(vec: vec3)))
    return new_color
}

struct GridView: View {
    @ObservedObject private var gridColors: ColorGridModel
    @ObservedObject private var offset: CGFloatModel
    
    init(width: Int, height: Int, default_color: Color = .white) {
        self._gridColors = ObservedObject(wrappedValue: ColorGridModel(width: width, height: height, initial_color: default_color))
        self._offset = ObservedObject(wrappedValue: CGFloatModel())
    }
    
    func update_color(i: Int, j: Int, c: Color) {
        self.gridColors.colors[i][j] = c
    }
    
    func shift_left() {
        print("updating offset")
        DispatchQueue.main.async {
            self.offset.value += 1.0
        }
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                let vertical_size: CGFloat = geometry.size.height / CGFloat(gridColors.colors.count)
                let horizontal_size: CGFloat = vertical_size
                ForEach(0..<gridColors.colors.count, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<gridColors.colors[rowIndex].count, id: \.self) { columnIndex in
                            CellView(color: gridColors.colors[rowIndex][columnIndex], width: horizontal_size, height: vertical_size)
                        }
                    }
                }
            }
            .offset(x: -geometry.size.width * self.offset.value)
//            .onAppear {
//                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
//                    offset = CGSize(width: -geometry.size.width, height: 0)
//                }
//            }
        }
    }
}

class Posteriorgram {
    var display: GridView
    var width: Int
    var height: Int
    var color_0: UIColor
    var color_1: UIColor
    var values: [[Float]]
    
    init(width: Int, height: Int, color_0: Color = .black, color_1: Color = .white) {
        self.width = width
        self.height = height
        self.display = GridView(width: width, height: height, default_color: .orange)
        self.color_0 = UIColor(color_0)
        self.color_1 = UIColor(color_1)
        self.values = Array(repeating: Array(repeating: 0.0, count: width), count: height)
    }
    
    func set_frame_distribution(frame_index: Int, distribution: [Float]) {
        assert(frame_index < self.width)
        assert(distribution.count == self.height)
        
        for i in 0..<distribution.count {
            self.values[i][frame_index] = distribution[i]
        }
    }
    
    func update_display() {
        for i in 0..<self.height {
            for j in 0..<self.width {
                let c = self.probability_to_color(prob: self.values[i][j])
                self.display.update_color(i: i, j: j, c: c)
            }
        }
    }
    
    func probability_to_color(prob: Float) -> Color {
        return linear_interpolate_colors(first: self.color_1, second: self.color_0, value: prob)
    }
}
