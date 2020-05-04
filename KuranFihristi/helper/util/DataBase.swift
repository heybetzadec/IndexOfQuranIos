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
    
    override init() {}

    
    func getDatabase() -> OpaquePointer? {
        let fileURL = Bundle.main.url(forResource: "index_app", withExtension: "db", subdirectory: "databases")!
        
        var db: OpaquePointer?
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return nil
        }
        return db
    }
    
    
    func getChapters(tranlationId:Int) -> Array<Chapter> {
        var list = Array<Chapter>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT ChapterID, ChapterName from Chapter WHERE TranslationID = \(tranlationId)", -1, &statement, nil) != SQLITE_OK {
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
    
    func getChapterName(chapterId: Int, tranlationId:Int) -> String {
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var chapterName = ""
        
        if sqlite3_prepare_v2(db, "SELECT ChapterName FROM Chapter WHERE TranslationID=\(tranlationId) AND ChapterID =\(chapterId)", -1, &statement, nil) != SQLITE_OK {
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
    
    
    func getVerses(chapterId:Int, tranlationId:Int) -> Array<Verse> {
        var list = Array<Verse>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT VerseID, VerseText  FROM Verse WHERE TranslationID=\(tranlationId) AND ChapterID=\(chapterId)", -1, &statement, nil) != SQLITE_OK {
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
    
    func getVerse(chapterId:Int, verseId:Int, tranlationId:Int) -> Verse {
        let item = Verse()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT VerseID, VerseText  FROM Verse WHERE TranslationID=\(tranlationId) AND ChapterID=\(chapterId) AND VerseID =\(verseId)", -1, &statement, nil) != SQLITE_OK {
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
    
    
    func getSearchVerses(searchWord:String, tranlationId:Int) -> Array<Verse> {
        var list = Array<Verse>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT ChapterID, VerseID, VerseText  FROM Verse WHERE TranslationID = \(tranlationId) AND VerseText LIKE '%\(searchWord)%'", -1, &statement, nil) != SQLITE_OK {
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
    
    
    func getRandomVerseBy(translationId:Int) -> VerseBy {
        let item = VerseBy()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        var beginId = 0
        var endId = 500
        
        if sqlite3_prepare_v2(db, "SELECT ID FROM Verse WHERE TranslationID = \(translationId) LIMIT 1", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            beginId = Int(sqlite3_column_int64(statement, 0))
            break
        }
        
        
        if sqlite3_prepare_v2(db, "SELECT ID  FROM  Verse WHERE TranslationID = \(translationId) ORDER BY ID DESC LIMIT 1", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            endId = Int(sqlite3_column_int64(statement, 0))
            break
        }
        
        let randomId = Int.random(in: beginId...endId)
        
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText FROM Verse v  " +
        "LEFT OUTER JOIN Chapter c ON v.ChapterID = c.ChapterID " +
        "WHERE v.TranslationID = \(translationId) AND c.TranslationID = \(translationId) AND v.ID = \(randomId)", -1, &statement, nil) != SQLITE_OK {
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
    
    
    func getVerseByTopic(topicId:Int, phraseId:Int, languageId:Int, translationId:Int) -> Array<VerseBy> {
        var list = Array<VerseBy>()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT v.ChapterID, c.ChapterName, v.VerseID, v.VerseText FROM VerseByPhrase AS vw  " +
        "LEFT OUTER JOIN Verse AS v ON v.ChapterID = vw.ChapterID AND v.VerseID = vw.VerseID  " +
        "LEFT OUTER JOIN Chapter AS c ON c.ChapterID = v.ChapterID AND c.TranslationID = v.TranslationID " +
        "WHERE vw.LangID=\(languageId) AND v.TranslationID=\(translationId)AND vw.ThemeID = \(topicId) AND vw.PhraseID = \(phraseId) ", -1, &statement, nil) != SQLITE_OK {
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
        
        if sqlite3_prepare_v2(db, "SELECT NameID, NameText, NameDescription, NameHtml FROM Name WHERE LangID = \(languageId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let item = Name()
            item.nameId = Int(sqlite3_column_int64(statement, 0))
            item.nameText = String(cString: sqlite3_column_text(statement, 1))
            item.nameDescription = String(cString: sqlite3_column_text(statement, 1))
            item.nameHtml = String(cString: sqlite3_column_text(statement, 1))
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
    
    
    
    func getName(nameId:Int, languageId:Int) -> Name {
        let item = Name()
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "SELECT NameID, NameText, NameDescription, NameHtml FROM Name WHERE LangID = \(languageId)  AND  NameID = \(nameId)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            item.nameId = Int(sqlite3_column_int64(statement, 0))
            item.nameText = String(cString: sqlite3_column_text(statement, 1))
            item.nameDescription = String(cString: sqlite3_column_text(statement, 1))
            item.nameHtml = String(cString: sqlite3_column_text(statement, 1))
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
    
    
    
    func getLanguages(languageId:Int) -> Array<Language> {
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
            item.languageCode = String(cString: sqlite3_column_text(statement, 1))
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
    
    
    func insertSavedVerse(verses: Array<Verse>) {
        let db = self.getDatabase()
        var statement: OpaquePointer?
        
        let insert = "INSERT INTO SaveVerse (ChapterID, VerseID) VALUES (?, ?);"
        
        for verse in verses {
            if(self.notExistSaved(chapterId: verse.chapterId, verseId: verse.verseId)){
                if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_int(statement, 1, Int32(verse.chapterId))
                    sqlite3_bind_int(statement, 2, Int32(verse.verseId))
                    if sqlite3_finalize(statement) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error finalizing prepared statement: \(errmsg)")
                    }
                }
            }
        }

        
//        if sqlite3_finalize(statement) != SQLITE_OK {
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error finalizing prepared statement: \(errmsg)")
//        }

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        statement = nil
    
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
        "WHERE v.TranslationID = \(translationId) AND c.TranslationID = \(translationId) ORDER BY sv.ID DESC;", -1, &statement, nil) != SQLITE_OK {
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
