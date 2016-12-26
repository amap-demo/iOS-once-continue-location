//
//  OnceContinueLocationUITests.m
//  OnceContinueLocationUITests
//
//  Created by hanxiaoming on 16/12/26.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface OnceContinueLocationUITests : XCTestCase

@end

@implementation OnceContinueLocationUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *toolbarsQuery = app.toolbars;
    XCUIElement *button = toolbarsQuery.buttons[@"\u8fdb\u884c\u5355\u6b21\u5b9a\u4f4d"];
    [button tap];

    
    XCUIElement *button2 = toolbarsQuery.buttons[@"\u8fdb\u884c\u8fde\u7eed\u5b9a\u4f4d"];
    [button2 tap];

    
    [button tap];
    [button2 tap];
}

@end
