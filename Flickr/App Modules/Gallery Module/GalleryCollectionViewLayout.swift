//
//  GalleryCollectionViewLayout.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 03.10.2021.
//

import UIKit

//protocol GalleryCollectionViewLayoutDelegate: AnyObject {
//    func collectionView(_ collectionView: UICollectionView, ratioForPhotoAtIndexPath indexPath: IndexPath) -> Float
//}
////let ratio = image.size.width / image.size.height
//
//class GalleryCollectionViewLayout: UICollectionViewLayout {
//    
//    weak var delegate: GalleryCollectionViewLayoutDelegate?
//    
//    private let cellPadding: CGFloat = 1
//    
//    private var cache: [UICollectionViewLayoutAttributes] = []
//    
//    private var contentWidth: CGFloat = 0
//    
//    private var contentHeight: CGFloat {
//        guard let collectionView = collectionView else {
//            return 0
//        }
//        //let insets = collectionView.contentInset
//        return collectionView.bounds.width / 3
//    }
//    
//    override var collectionViewContentSize: CGSize {
//        return CGSize(width: contentWidth, height: contentHeight)
//    }
//    
//    
//    
//    override func prepare() {
//        super.prepare()
//        
//        guard
//            cache.isEmpty,
//            let collectionView = collectionView
//        else {
//            return
//        }
//        
//        let columnWidth: CGFloat
//        
//        for item in 0..<collectionView.numberOfItems(inSection: 0) {
//            let indexPath = IndexPath(item: item, section: 0)
//            
//            if let photoRatio = delegate?.collectionView(collectionView, ratioForPhotoAtIndexPath: indexPath) {
//                switch photoRatio {
//                case (...1.5):
//                    columnWidth = contentWidth / 3
//                case (...2.5):
//                    columnWidth = contentWidth / 2
//                default:
//                    columnWidth = contentWidth
//                }
//            }
//            
//            let width = cellPadding * 2 + photoWidth.width
//            let frame = CGRect(x: 1,
//                               y: 1,
//                               width: width,
//                               height: columnHeight)
//            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
//            
//            
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            attributes.frame = insetFrame
//            cache.append(attributes)
//            
//            contentWidth = max(contentWidth, frame.maxX)
//            yOffset[column] = yOffset[column] + columnHeight
//        }
//        
//        var xOffset: [ CGFloat ] = []
//        for column  0 ..<numberOfColumns {
//            xOffset.append ( CGFloat (column) * columnWidth)
//        }
//        
//        
//        var column =  0
//        var yOffset: [ CGFloat ] = . init (повторение: 0 , счетчик: numberOfColumns)
//        
//        
//        var xOffset: [CGFloat] = []
//        let columnHeight = contentHeight / CGFloat(3)
//        
//        for column in 0..<numberOfColumns {
//            xOffset.append(CGFloat(column) * columnWidth)
//            
//        }
//        var column = 0
//        var yOffset: [CGFloat] = .init(repeating: 0, count: 3)
//        
//        // 3
//        for item in 0..<collectionView.numberOfItems(inSection: 0) {
//            let indexPath = IndexPath(item: item, section: 0)
//            
//            let photoWidth = delegate?.collectionView(collectionView, widthForPhotoAtIndexPath: indexPath)
//            switch 1.0 {
//            case ...1.5:
//                break
//            default:
//                break
//            }
//            
//            
//            
//            let width = cellPadding * 2 + photoWidth.width
//            let frame = CGRect(x: 1,
//                               y: 1,
//                               width: width,
//                               height: columnHeight)
//            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
//            
//            
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            attributes.frame = insetFrame
//            cache.append(attributes)
//            
//            contentWidth = max(contentWidth, frame.maxX)
//            yOffset[column] = yOffset[column] + columnHeight
//            
//        }
//    }
//    
//    override func layoutAttributesForElements(in rect: CGRect)
//    -> [UICollectionViewLayoutAttributes]? {
//        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
//        
//        // Loop through the cache and look for items in the rect
//        for attributes in cache {
//            if attributes.frame.intersects(rect) {
//                visibleLayoutAttributes.append(attributes)
//            }
//        }
//        return visibleLayoutAttributes
//    }
//    
//    override func layoutAttributesForItem(at indexPath: IndexPath)
//    -> UICollectionViewLayoutAttributes? {
//        return cache[indexPath.item]
//    }
//}
