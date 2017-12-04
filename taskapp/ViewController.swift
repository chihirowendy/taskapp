//
//  ViewController.swift
//  taskapp
//
//  Created by Chihiro Endo on 2017/11/25.
//  Copyright © 2017年 Chihiro Endo. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
  
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //データ
    //let docs = realm.objects("Task".self)
    
    // 文字列で検索条件を指定します
//    var tanTask = realm.objects(Task).filter("color = 'tan' AND name BEGINSWITH ‘String’”)
    
    // NSPredicateを使って検索条件を指定します
    let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "String")
//    tanTask = realm.objects(Task).filter(predicate)
    
  //検索結果配列
    var searchResult = [String]()

//最初からあるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()

        //デリゲート先を自分に設定する。
        SearchBar.delegate = self

        //何も入力されていなくてもReturnキーを押せるようにする。
        SearchBar.enablesReturnKeyAutomatically = false

        //検索結果配列にデータをコピーする。
        searchResult = realm.objects("Task".self)
    }



    //データを返すメソッド
func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{

        //セルを取得する。
        let cell = tableView.dequeueReusableCellWithIdentifier("TestCell", forIndexPath:indexPath) as UITableViewCell

        cell.textLabel?.text = searchResult[indexPath.row]
        return cell
    }


    //データの個数を返すメソッド
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return searchResult.count
    }


    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        SearchBar.endEditing(true)

        //検索結果配列を空にする。
        searchResult.removeAll()

        if(SearchBar.text == "") {
//検索文字列が空の場合はすべてを表示する。
            searchResult = realm.objects(Task)
        } else {
            
            //検索文字列を含むデータを検索結果配列に追加する。
            for data in realm.objects(Task.self) {
                if data.containsString(SearchBar.text!) {
                    searchResult.append(data)
                }
            }
        }

        //テーブルを再読み込みする。
        testTableView.reloadData()
    }
    

  
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
  
    
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
}

