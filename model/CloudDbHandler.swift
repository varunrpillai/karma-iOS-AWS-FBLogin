//
//  CloudDbHandler.swift
//  Karma
//
// Wrapper around KarmaObject that represents the cloud db.
// This class performs create, read, update, delete, query on the cloud db.
//
//  Created by Varun Ramachandran on 3/1/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

import Foundation
import AWSCore
import AWSDynamoDB

@objc public class CloudDbHandler : NSObject {
	
	static let sharedInstance = CloudDbHandler()
	
	@objc func createKarma(id:String, karmaSet:Set<Data>?) {
		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
		
		// Create data object using data models you downloaded from Mobile Hub
		let karmaItem: KarmaObject = KarmaObject()

		karmaItem._userId = id;
		karmaItem._karmaSet = karmaSet

		//Save a new item
		dynamoDbObjectMapper.save(karmaItem, completionHandler: {
			(error: Error?) -> Void in
			
			if let error = error {
				print("Amazon DynamoDB Save Error: \(error)")
				return
			}
			print("An item was saved.")
		})
	}
	
	
	@objc func readKarma(id:String) {
		
		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
		
		// Create data object using data models downloaded from Amazon Mobile Hub
		let karmaItem: KarmaObject = KarmaObject();
		karmaItem._userId = id
		
		dynamoDbObjectMapper.load(
			KarmaObject.self,
			hashKey: karmaItem._userId!,
			rangeKey: karmaItem._userId!,
			completionHandler: {
				(objectModel: AWSDynamoDBObjectModel?, error: Error?) -> Void in
				if let error = error {
					print("Amazon DynamoDB Read Error: \(error)")
					return
				}
				print("An item was read.")
		})
	}
	
	
	
	@objc func updateKarma(id:String, karmaSet:Set<Data>) {
		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
		
		let karmaItem: KarmaObject = KarmaObject();
		karmaItem._userId = id
		karmaItem._karmaSet = karmaSet
		
		dynamoDbObjectMapper.save(karmaItem, completionHandler: {(error: Error?) -> Void in
			if let error = error {
				print(" Amazon DynamoDB Save Error: \(error)")
				return
			}
			print("An item was updated.")
		})
	}
	
	
	@objc func deleteKarma(id:String) {
		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
		
		let itemToDelete = KarmaObject()
		itemToDelete?._userId = id
		
		dynamoDbObjectMapper.remove(itemToDelete!, completionHandler: {(error: Error?) -> Void in
			if let error = error {
				print(" Amazon DynamoDB Save Error: \(error)")
				return
			}
			print("An item was deleted.")
		})
	}
	
	@objc func queryKarmas(id:String, onCompletion: @escaping (Set<Data>) -> Void) {
		var karmaSet: Set<Data> = Set<Data>()
		// 1) Configure the query
		let queryExpression = AWSDynamoDBQueryExpression()
		queryExpression.keyConditionExpression = "#userId = :userId"
		
		queryExpression.expressionAttributeNames = [
			"#userId": "userId",
		]
		queryExpression.expressionAttributeValues = [
			":userId": id
		]
		
		// 2) Make the query
		
		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
		
		dynamoDbObjectMapper.query(KarmaObject.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
			if error != nil {
				print("The request failed. Error: \(String(describing: error))")
			}
			
			
			if output != nil {
				for karmas in output!.items {
					let karmaItem = karmas as? KarmaObject
					karmaSet = (karmaItem?._karmaSet)!
					break
				}
			}
			onCompletion(karmaSet)
		}
	}
}
