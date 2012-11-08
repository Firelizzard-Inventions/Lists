//
//  definitions.h
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#pragma mark Other

#define FIEmptyString				@""

#pragma mark - Identifiers

#define FIListsGroupUIElem			@"com.firelizzard.Lists.uielem.group"
#define FIListsListUIElem			@"com.firelizzard.Lists.uielem.list"
#define FIListsErrorUIElem			@"com.firelizzard.Lists.uielem.error"
#define FIListsTableUIElem			@"com.firelizzard.Lists.uielem.table"
#define FIListsFieldUIElem			@"com.firelizzard.Lists.uielem.field"

#define FIListsAddSegue				@"com.firelizzard.Lists.segue.lists.add"
#define FIListsAddGroupSegue		@"com.firelizzard.Lists.segue.lists.add.group"
#define FIListsAddListSegue			@"com.firelizzard.Lists.segue.lists.add.list"
#define FIListsOpenGroupSegue		@"com.firelizzard.Lists.segue.lists.open.group"
#define FIListsOpenListSegue		@"com.firelizzard.Lists.segue.lists.open.list"
#define FIListsOpenErrorSegue		@"com.firelizzard.Lists.segue.lists.open.error"
#define FIListsEditGroupSegue		@"com.firelizzard.Lists.segue.lists.edit.group"
#define FIListsEditListSegue		@"com.firelizzard.Lists.segue.lists.edit.list"
#define FIListsEditTableSegue		@"com.firelizzard.Lists.segue.lists.edit.table"
#define FIListsEditFieldSegue		@"com.firelizzard.Lists.segue.lists.edit.field"
#define FIListsEditGroupParentSegue	@"com.firelizzard.Lists.segue.lists.edit.group.parent"

#pragma mark - Entry Strings

#define FIEntryKeyID				@"id"
#define FIEntryKeyName				@"name"
#define FIEntryKeyType				@"type"
#define FIEntryKeyParent			@"parent"
#define FIEntryKeyError				@"error"
#define FIEntryKeyECode				@"ecode"

#define FIEntryTypeGroup			@"group"
#define FIEntryTypeList				@"list"
#define FIEntryTypeAll				@"all"

#pragma mark - Error Codes

// Database Errors
#define FIDatabaseGenericError		100

// Model Errors
#define FIModelGenericError			200
#define FIModelNullResultError		201
#define FIModelNullIDError			202
#define FIModelNullNameError		203
#define FIModelNullTypeError		204
#define FIModelNullParentError		205
#define FIModelUnknownTypeError		206

// View Errors
#define FIViewGenericError			300
#define FIViewEmptySectionError		301
