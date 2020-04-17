//
//  TextFormat.swift
//  CoordinatorTests
//
//  Created by Chris Moore on 4/16/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import XCTest
@testable import Coordinator

class TextFormat: XCTestCase {
    func testExample() throws {
        let json = """
            {
               "by":"semisight",
               "descendants":166,
               "id":22827833,
               "kids":[
                  22828928,
                  22829798,
                  22828849
               ],
               "score":314,
               "text":"Context upfront: <a href=\\"https:&#x2F;&#x2F;news.ycombinator.com&#x2F;item?id=13771203\\" rel=\\"nofollow\\">https:&#x2F;&#x2F;news.ycombinator.com&#x2F;item?id=13771203</a><p>I&#x27;d really like to have a decent (let&#x27;s say &gt;13&quot;) display to hang on a wall in my room and display weather, my todo list, etc. It doesn&#x27;t necessarily have to be E-ink proper, but I like the idea of having something that doesn&#x27;t emit its own light. More like an electronic whiteboard.<p>Alternatives include something like the Vestaboard, which is <i>not cheap</i>, and probably fairly noisy.<p>Are there products I&#x27;m missing here?",
               "time":1586471076,
               "title":"Ask HN: Has any progress been made on large format E-ink displays?",
               "type":"story"
            }
            """
        
        let expectedText = """
<html>
 <head></head>
 <body>
  <p>Context upfront: <a href="https://news.ycombinator.com/item?id=13771203" rel="nofollow">https://news.ycombinator.com/item?id=13771203</a></p>
  <p>I'd really like to have a decent (let's say &gt;13") display to hang on a wall in my room and display weather, my todo list, etc. It doesn't necessarily have to be E-ink proper, but I like the idea of having something that doesn't emit its own light. More like an electronic whiteboard.</p>
  <p>Alternatives include something like the Vestaboard, which is <i>not cheap</i>, and probably fairly noisy.</p>
  <p>Are there products I'm missing here?</p>
 </body>
</html>
"""
        
        guard let jsonData = json.data(using: .utf8) else { return XCTFail() }
        print(jsonData)
        let item = try JSONDecoder().decode(HNItem.self, from: jsonData)
        
        XCTAssertEqual(expectedText, item.formattedHTML)
    }
}
