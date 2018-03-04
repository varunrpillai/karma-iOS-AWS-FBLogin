//
//  KarmaObject.swift
//  Karma
//
// The object that is send to AWS Dynamo DB
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.19
//

import Foundation
import UIKit
import AWSDynamoDB

class KarmaObject: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
	
	var _userId: String?
	var _karmaSet: Set<Data>?
	
	class func dynamoDBTableName() -> String {
		
		return "karma-mobilehub-1421855317-karma"
	}
	
	class func hashKeyAttribute() -> String {
		
		return "_userId"
	}
	
	override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
		return [
			"_userId" : "userId",
			"_karmaSet" : "karmaSet",
		]
	}
}
