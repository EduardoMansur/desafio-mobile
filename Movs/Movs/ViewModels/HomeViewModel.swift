//
//  HomeViewModel.swift
//  Movs
//
//  Created by Eduardo Pereira on 26/08/19.
//  Copyright © 2019 Eduardo Pereira. All rights reserved.
//

import UIKit
protocol Refresh:AnyObject {
    func removeRefresher()
    func addRefresher()
}
class HomeViewModel:NSObject{
    private var page = 1
    var dataAcess:DataAcess
    private var currentRequest = Request.popular
    var data:[MovieCellViewModel] = []
    var displayPage:(()->Void)?
    var didSelect:((MovieCellViewModel)->Void)?
    var uiHandler:(()->Void)?
    var refreshHandler:Refresh?
    var backgroundImage = UIImage(named: "black_background")
    //Could use NSlocalizable string to have more languages
    var segmentItens = ["Upcoming","Popular"]
   // private var cellSize:CGSize
    
    init(dataAcess:DataAcess,uiHandler:(()->Void)? = nil,refreshHandler:Refresh? = nil) {
        self.dataAcess = dataAcess
        self.uiHandler = uiHandler
        self.refreshHandler = refreshHandler
        super.init()
        refreshHandler?.addRefresher()
        dataAcess.getMovies(request: Request.popular, page: page) { [weak self](result) in
            guard let self = self,let result = result else{
                return
            }
            self.refreshHandler?.removeRefresher()
            self.appendMovies(movies: result)
        }
    }
    func appendMovies(movies:[Movie]) {
        movies.forEach { (movie) in
            let model = MovieCellViewModel(movie: movie, dataAcess: dataAcess, uiHandler: uiHandler)
            self.data.append(model)
        }
        uiHandler?()
    }
    private func resetPage(){
        self.page = 1
      
    }

    func changeData(request:Request){
        resetPage()
        self.data = []
        uiHandler?()
        refreshHandler?.addRefresher()
        currentRequest = request
        dataAcess.getMovies(request: request, page: self.page) { [weak self](results) in
            guard let self = self,let results = results else{
                return
            }
            self.refreshHandler?.removeRefresher()
            self.appendMovies(movies: results)
        }
    }
    private func addPage(){
        self.page += 1
        dataAcess.getMovies(request: currentRequest, page: self.page) { [weak self](results) in
            guard let self = self,let results = results else{
                return
            }
            self.appendMovies(movies: results)
        }
    }
    func configureNavBar(navController:UINavigationController?){
        navController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController?.navigationBar.shadowImage = UIImage()
        navController?.navigationBar.isTranslucent = true
        navController?.view.backgroundColor = .clear
        navController?.navigationBar.isHidden = false
    }

    
}

extension HomeViewModel:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else{
            return MovieCollectionViewCell()
        }
        cell.setUpCell(movie: data[indexPath.item])
        return cell
    }
    
}
extension HomeViewModel:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: review
        self.didSelect?(data[indexPath.item])
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == data.count - 3{
            self.addPage()
        }
    }
}
