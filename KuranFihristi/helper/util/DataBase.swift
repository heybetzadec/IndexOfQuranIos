//
//  DataBase.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SQLite3

class DataBase: NSObject {
    
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override init() {}

    
    func getDatabase() -> OpaquePointer? {
        let fileURL = Bundle.main.url(forResource: "index_app", withExtension: "db", subdirectory: "Library/Application support")!
        
        var db: OpaquePointer?
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return nil
        }
        return db
    }
    
    
    func getChapters(translationId:Int, selectedOrder: Int) -> Array<Chapter> {
        var list = Array<Chapter>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var orderBy = ""
        if selectedOrder == 1 {
            orderBy = " ORDER BY DescentID ASC";
        }
        
        if sqlite3_prepare_v2(db, "SELECT ChapterID, ChapterName from Chapter WHERE TranslationID = \(translationId) \(orderBy)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Chapter(chapterId: 0, chapterName: "")
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.chapterName = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getChapterName(chapterId: Int, translationId:Int) -> String {
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var chapterName = ""
        
        if sqlite3_prepare_v2(db, "SELECT ChapterName FROM Chapter WHERE TranslationID=\(translationId) AND ChapterID =\(chapterId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            chapterName = String(cString: sqlite3_column_text(statement, 0))
            break
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return chapterName
    }
    
    
    func getVerses(chapterId:Int, translationId:Int) -> Array<Verse> {
        var list = Array<Verse>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT VerseID, VerseText  FROM Verse WHERE TranslationID=\(translationId) AND ChapterID=\(chapterId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Verse()
            item.chapterId = chapterId
            item.verseId = Int(sqlite3_column_int64(statement, 0))
            item.verseText = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getVerse(chapterId:Int, verseId:Int, translationId:Int) -> Verse {
        let item = Verse()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT VerseID, VerseText  FROM Verse WHERE TranslationID=\(translationId) AND ChapterID=\(chapterId) AND VerseID =\(verseId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            item.chapterId = chapterId
            item.verseId = Int(sqlite3_column_int64(statement, 0))
            item.verseText = String(cString: sqlite3_column_text(statement, 1))
            break
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return item
    }
    
    
    func getSearchVerses(searchWord:String, translationId:Int) -> Array<Verse> {
        var list = Array<Verse>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT ChapterID, VerseID, VerseText  FROM Verse WHERE TranslationID = \(translationId) AND VerseText LIKE '%\(searchWord)%'", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Verse()
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.verseId = Int(sqlite3_column_int64(statement, 1))
            item.verseText = String(cString: sqlite3_column_text(statement, 2))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getLettersWords(languageId:Int, searchText: String) -> Array<Letter> {
        var list = Array<Letter>()
        var letterId = 0
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var search = ""
        
        if !searchText.isEmpty {
            search = " AND WordName LIKE '%\(searchText)%'"
        }
//        "SELECT l.LetterID, w.WordID,  w.WordName FROM Word w LEFT OUTER JOIN Letter l ON l.LetterID == w.LetterId WHERE w.LangID = \(languageId) AND w.LangID = \(languageId) \(search) GROUP BY w.ID"
        if sqlite3_prepare_v2(db, "SELECT LetterID, WordID,  WordName FROM Word WHERE LangID = \(languageId)  \(search)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let thisLetterId = Int(sqlite3_column_int64(statement, 0))
            if thisLetterId != letterId {
                letterId = thisLetterId
                let item = Letter()
                let wordName = String(cString: sqlite3_column_text(statement, 2))
                item.letterId = thisLetterId
                item.letterName = String(wordName.prefix(1)) //String(cString: sqlite3_column_text(statement, 1))
                let word = Word(wordId: Int(sqlite3_column_int64(statement, 1)), wordName:  wordName)
                item.words = [word]
                list.append(item)
            } else {
                let letter = list.first { (Letter) -> Bool in
                    Letter.letterId == letterId
                }
                let word = Word(wordId: Int(sqlite3_column_int64(statement, 1)), wordName:  String(cString: sqlite3_column_text(statement, 2)))
                letter?.words.append(word)
            }
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getLetters(languageId:Int) -> Array<Letter> {
        var list = Array<Letter>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT  LetterID, LetterName  FROM Letter WHERE LangID = \(languageId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Letter()
            item.letterId = Int(sqlite3_column_int64(statement, 0))
            item.letterName = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    func getWords(letterId:Int, languageId:Int) -> Array<Word> {
        var list = Array<Word>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT  WordID, WordName FROM Word WHERE LangID = \(languageId) AND LetterID = \(letterId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Word()
            item.wordId = Int(sqlite3_column_int64(statement, 0))
            item.wordName = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getVerseByWords(letterId:Int, wordId:Int, languageId:Int, translationId:Int) -> Array<VerseBy> {
        var list = Array<VerseBy>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText  FROM VerseByWord AS vw " +
        "LEFT OUTER JOIN Verse AS v ON v.ChapterID = vw.ChapterID AND v.VerseID = vw.VerseID " +
        "LEFT OUTER JOIN Chapter AS c ON c.ChapterID = v.ChapterID AND c.TranslationID = v.TranslationID " +
        "WHERE vw.LangID=\(languageId) AND v.TranslationID=\(translationId) AND vw.LetterID = \(letterId) AND vw.WordId = \(wordId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = VerseBy()
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.chapterName = String(cString: sqlite3_column_text(statement, 1))
            item.verseId = Int(sqlite3_column_int64(statement, 2))
            item.verseText = String(cString: sqlite3_column_text(statement, 3))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    private func getVerseBeginId(translationId:Int) -> Int {
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var beginId = 1
        
        if sqlite3_prepare_v2(db, "SELECT ID FROM Verse WHERE TranslationID = \(translationId) LIMIT 1;", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            beginId = Int(sqlite3_column_int64(statement, 0))
            break
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return beginId
    }
    
    private func getVerseLastId(translationId:Int) -> Int {
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var lastId = 1
        
        if sqlite3_prepare_v2(db, "SELECT ID  FROM  Verse WHERE TranslationID = \(translationId) ORDER BY ID DESC LIMIT 1;", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            lastId = Int(sqlite3_column_int64(statement, 0))
            break
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return lastId
    }
    
    
    func getRandomVerseBy(translationId:Int) -> VerseBy {
        let item = VerseBy()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var beginId = 0
        var endId = 500
        
        beginId = self.getVerseBeginId(translationId: translationId)
        endId = self.getVerseLastId(translationId: translationId)
        
        let randomId = Int.random(in: beginId...endId)
        
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText FROM Verse v  " +
        "LEFT OUTER JOIN Chapter c ON v.ChapterID = c.ChapterID " +
            "WHERE v.TranslationID = \(translationId) AND c.TranslationID = \(translationId) AND v.ID = \(randomId);", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.chapterName = String(cString: sqlite3_column_text(statement, 1))
            item.verseId = Int(sqlite3_column_int64(statement, 2))
            item.verseText = String(cString: sqlite3_column_text(statement, 3))
            break
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        
        return item
    }
    
    func getLifes(languageId:Int) -> Array<Life> {
        var list = Array<Life>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT LifeId, LifeName From Life WHERE LangID = \(languageId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Life()
            item.lifeId = Int(sqlite3_column_int64(statement, 0))
            item.lifeName = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getVerseByLife(lifeId:Int, translationId:Int) -> Array<VerseBy> {
        var list = Array<VerseBy>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText FROM VerseByLife AS vl LEFT OUTER JOIN Verse AS v ON v.ChapterID = vl.ChapterID AND v.VerseID = vl.VerseID LEFT OUTER JOIN Chapter AS c ON c.ChapterID = v.ChapterID AND c.TranslationID = v.TranslationID WHERE v.TranslationID=\(translationId) AND vl.LifeId = \(lifeId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = VerseBy()
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.chapterName = String(cString: sqlite3_column_text(statement, 1))
            item.verseId = Int(sqlite3_column_int64(statement, 2))
            item.verseText = String(cString: sqlite3_column_text(statement, 3))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    func getTopics(languageId:Int) -> Array<Topic> {
        var list = Array<Topic>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT  ThemeID, ThemeName  FROM Theme WHERE LangID= \(languageId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Topic()
            item.topicId = Int(sqlite3_column_int64(statement, 0))
            item.topicName = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    
    func getPhrase(topicId:Int, languageId:Int) -> Array<Phrase> {
        var list = Array<Phrase>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT PhraseID, PhraseName FROM Phrase WHERE LangID=\(languageId) AND ThemeID=\(topicId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Phrase()
            item.phraseId = Int(sqlite3_column_int64(statement, 0))
            item.phraseName = String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    func getVerseByTopic(topicId:Int, phraseId:Int, translationId:Int) -> Array<VerseBy> {
        var list = Array<VerseBy>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText FROM VerseByPhrase AS vw  " +
        "LEFT OUTER JOIN Verse AS v ON v.ChapterID = vw.ChapterID AND v.VerseID = vw.VerseID  " +
        "LEFT OUTER JOIN Chapter AS c ON c.ChapterID = v.ChapterID AND c.TranslationID = v.TranslationID " +
        "WHERE v.TranslationID=\(translationId) AND vw.ThemeID = \(topicId) AND vw.PhraseID = \(phraseId) ", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = VerseBy()
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.chapterName = String(cString: sqlite3_column_text(statement, 1))
            item.verseId = Int(sqlite3_column_int64(statement, 2))
            item.verseText = String(cString: sqlite3_column_text(statement, 3))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    
    func getNames(languageId:Int) -> Array<Name> {
        var list = Array<Name>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT NameID, NameText, NameDescription FROM Name WHERE LangID = \(languageId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Name()
            item.nameId = Int(sqlite3_column_int64(statement, 0))
            item.nameText = String(cString: sqlite3_column_text(statement, 1))
            item.nameDescription = String(cString: sqlite3_column_text(statement, 2))
            item.nameHtml = ""//String(cString: sqlite3_column_text(statement, 1))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    
    func getNameHtml(nameId:Int, languageId:Int) -> String {
        var text = ""
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT NameHtml FROM Name WHERE LangID = \(languageId)  AND  NameID = \(nameId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            text = String(cString: sqlite3_column_text(statement, 0))
            break
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return text
    }
    
    
    
    func getLanguages() -> Array<Language> {
        var list = Array<Language>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT LanguageId, LanguageName, LangCode FROM Language ORDER BY LanguageName", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Language()
            item.languageId = Int(sqlite3_column_int64(statement, 0))
            item.languageName = String(cString: sqlite3_column_text(statement, 1))
            item.languageCode = String(cString: sqlite3_column_text(statement, 2))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func getTranslations(languageId:Int) -> Array<Translation> {
        var list = Array<Translation>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT TranslationId, TranslationName, LangID FROM Translation WHERE langID = \(languageId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Translation()
            item.translationId = Int(sqlite3_column_int64(statement, 0))
            item.translationName = String(cString: sqlite3_column_text(statement, 1))
            item.languageId = languageId
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    
    func getReminders() -> Array<Reminder> {
        var list = Array<Reminder>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT ID, Hour, Minute, IsActive FROM Reminder ORDER BY ID DESC", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Reminder()
            item.id = Int(sqlite3_column_int64(statement, 0))
            item.hour = Int(sqlite3_column_int64(statement, 1))
            item.minute = Int(sqlite3_column_int64(statement, 2))
            item.isActive = Int(sqlite3_column_int64(statement, 3))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }
    
    func insertReminder(reminder: Reminder){
        var db = self.getDatabase()
        
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, "INSERT INTO Reminder (Hour, Minute, IsActive) VALUES (?, ?, ?);", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        sqlite3_bind_int(statement, 1, Int32(reminder.hour))
        sqlite3_bind_int(statement, 2, Int32(reminder.minute))
        sqlite3_bind_int(statement, 3, Int32(reminder.isActive))
        

//        if sqlite3_bind_text(statement, 1, "foo", -1, SQLITE_TRANSIENT) != SQLITE_OK {
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("failure binding foo: \(errmsg)")
//        }

        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting foo: \(errmsg)")
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database: -> \(String(describing: sqlite3_errmsg(db))), \(String(describing: db))")
        }

        db = nil
        statement = nil
        
//        print("close = \(sqlite3_close(db))")
        
        
//        let insertStatementString = "INSERT INTO Reminder (Hour, Minute, IsActive) VALUES (?, ?, ?);"
//        var insertStatement: OpaquePointer?
//        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) ==
//            SQLITE_OK {
//            sqlite3_bind_int(insertStatement, 1, Int32(reminder.hour))
//            sqlite3_bind_int(insertStatement, 2, Int32(reminder.minute))
//            sqlite3_bind_int(insertStatement, 3, Int32(reminder.isActive))
//          if sqlite3_step(insertStatement) == SQLITE_DONE {
//            print("\nSuccessfully inserted row.")
//          } else {
//            print("\nCould not insert row.")
//          }
//        } else {
//          print("\nINSERT statement is not prepared.")
//        }
//        sqlite3_finalize(insertStatement)
//
//        if sqlite3_close(db) != SQLITE_OK {
//            print("error closing database")
//        }
//        insertStatement = nil
    }
    
    func updateReminder(reminder: Reminder){
        let db = self.getDatabase()
        
        var updateStatement: OpaquePointer?
        
        let updateStatementString = "UPDATE Reminder SET Hour = \(reminder.hour), Minute = \(reminder.minute), IsActive = \(reminder.isActive)  WHERE Id = \(reminder.id);"
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) ==
            SQLITE_OK {
          if sqlite3_step(updateStatement) == SQLITE_DONE {
            print("\nSuccessfully updated row.")
          } else {
            print("\nCould not update row.")
          }
        } else {
          print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
        
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
    }
    
    
    func deleteReminder(reminder: Reminder) {
    let db = self.getDatabase()
      var deleteStatement: OpaquePointer?
        
        let deleteStatementString = "DELETE FROM Reminder WHERE ID = \(reminder.id);"
        
      if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
          print("\nSuccessfully deleted row.")
        } else {
          print("\nCould not delete row.")
        }
      } else {
        print("\nDELETE statement could not be prepared")
      }
        
      sqlite3_finalize(deleteStatement)
    }
    
    func insertSavedVerse(verses: Array<Verse>) {
        let db = self.getDatabase()
        let insertStatementString = "INSERT INTO SaveVerse (ChapterID, VerseID) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        // 1
        for verse in verses {
            if(self.notExistSaved(chapterId: verse.chapterId, verseId: verse.verseId)){
                if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) ==
                    SQLITE_OK {
                    sqlite3_bind_int(insertStatement, 1, Int32(verse.chapterId))
                    sqlite3_bind_int(insertStatement, 2, Int32(verse.verseId))
                  if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("\nSuccessfully inserted row.")
                  } else {
                    print("\nCould not insert row.")
                  }
                } else {
                  print("\nINSERT statement is not prepared.")
                }
            }
        }
        // 5
        sqlite3_finalize(insertStatement)
        
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        insertStatement = nil
    }
    
    private func notExistSaved(chapterId:Int, verseId:Int) -> Bool {
        var notExist = true
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT ChapterID, VerseID FROM SaveVerse WHERE ChapterID = \(chapterId) AND VerseID = \(verseId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            notExist = false
            break
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return notExist
    }
    
    func clearAllSaved(){
        let db = self.getDatabase()
        if sqlite3_exec(db, "DELETE FROM SaveVerse", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
    }
    
    
    func clearSaved(chapterId:Int, verseId:Int){
        let db = self.getDatabase()
        if sqlite3_exec(db, "DELETE FROM SaveVerse WHERE ChapterID = \(chapterId) AND VerseId = \(verseId)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
    }
    
    func getVerseByPin(translationId:Int) -> Array<VerseBy> {
        var list = Array<VerseBy>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText FROM SaveVerse sv LEFT OUTER JOIN " +
        "Verse v ON  v.ChapterID = sv.ChapterID AND v.VerseID = sv.VerseID LEFT OUTER JOIN " +
        "Chapter c ON v.ChapterID = c.ChapterID " +
        "WHERE v.TranslationID = \(translationId) AND c.TranslationID = \(translationId) ORDER BY sv.ID DESC", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = VerseBy()
            item.chapterId = Int(sqlite3_column_int64(statement, 0))
            item.chapterName = String(cString: sqlite3_column_text(statement, 1))
            item.verseId = Int(sqlite3_column_int64(statement, 2))
            item.verseText = String(cString: sqlite3_column_text(statement, 3))
            list.append(item)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
        return list
    }

    
    func getSaved() {
        print("saved")
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT ChapterID, VerseID FROM SaveVerse", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let ChapterID = Int(sqlite3_column_int64(statement, 0))
            let VerseID = String(cString: sqlite3_column_text(statement, 1))
            print("\(ChapterID) - \(VerseID)")
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
    }
    
    
}



extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0

        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }

        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)

        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
