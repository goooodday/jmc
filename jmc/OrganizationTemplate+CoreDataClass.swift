//
//  OrganizationTemplate+CoreDataClass.swift
//  jmc
//
//  Created by John Moody on 6/10/17.
//  Copyright © 2017 John Moody. All rights reserved.
//

import Foundation
import CoreData


public class OrganizationTemplate: NSManagedObject {
    
    func validateTemplate() -> Bool {
        //every template should be technically valid, but for the sake of convenience, we probably want to mandate that templates have at least one token, and contain a trackname token, at the very least
        //very "at own risk"
        guard let template = self.tokens as? [OrganizationFieldToken] else { return false }
        guard template.contains(where: {$0.tokenType != .other}) else { return false }
        guard template.contains(where: {$0.tokenType == .trackname}) else { return false }
        return true
    }
    
    func getURL(for track: Track, withExtension pathExtension: String) -> URL? {
        guard let template = self.tokens as? [OrganizationFieldToken], let baseURL = URL(string: self.base_url_string!) else { return nil }
        let urlPathComponents = template.map({return transformToPathComponent(token: $0, track: track)}).joined().components(separatedBy: "/")
        for component in urlPathComponents {
            return baseURL.appendingPathComponent(component)
        }
        return baseURL.appendingPathExtension(pathExtension)
    }
    
    func transformToPathComponent(token: OrganizationFieldToken, track: Track) -> String {
        switch token.tokenType {
        case .album:
            return track.album?.name ?? UNKNOWN_ALBUM_STRING
        case .albumartist:
            return track.album?.album_artist?.name ?? track.artist?.name ?? UNKNOWN_ARTIST_STRING
        case .artist:
            return track.artist?.name ?? UNKNOWN_ARTIST_STRING
        case .other:
            return token.stringIfOther!
        case .trackname:
            return track.name ?? ""
        case .tracknum:
            return track.track_num?.stringValue ?? ""
        case .year:
            return track.album?.release_date?.description ?? ""
        }
    }

}
