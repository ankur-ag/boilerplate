import Foundation
import SwiftUI

// MARK: - Sport Type

enum SportType: String, Codable, CaseIterable {
    case nba = "NBA"
    case nfl = "NFL"
    
    var icon: String {
        switch self {
        case .nba: return "basketball.fill"
        case .nfl: return "football.fill"
        }
    }
}

// MARK: - Sports Team

struct SportsTeam: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let abbreviation: String
    let sport: SportType
    let conference: String
    let division: String
    let primaryColor: String
    let secondaryColor: String
    
    var fullName: String {
        "\(city) \(name)"
    }
}

// MARK: - NBA Data

enum NBAData {
    static let allTeams: [SportsTeam] = [
        // Eastern - Atlantic
        SportsTeam(id: "BOS", name: "Celtics", city: "Boston", abbreviation: "BOS", sport: .nba, conference: "Eastern", division: "Atlantic", primaryColor: "007A33", secondaryColor: "BA9653"),
        SportsTeam(id: "BKN", name: "Nets", city: "Brooklyn", abbreviation: "BKN", sport: .nba, conference: "Eastern", division: "Atlantic", primaryColor: "000000", secondaryColor: "FFFFFF"),
        SportsTeam(id: "NYK", name: "Knicks", city: "New York", abbreviation: "NYK", sport: .nba, conference: "Eastern", division: "Atlantic", primaryColor: "006BB6", secondaryColor: "F58426"),
        SportsTeam(id: "PHI", name: "76ers", city: "Philadelphia", abbreviation: "PHI", sport: .nba, conference: "Eastern", division: "Atlantic", primaryColor: "006BB6", secondaryColor: "ED174C"),
        SportsTeam(id: "TOR", name: "Raptors", city: "Toronto", abbreviation: "TOR", sport: .nba, conference: "Eastern", division: "Atlantic", primaryColor: "CE1141", secondaryColor: "000000"),
        
        // Eastern - Central
        SportsTeam(id: "CHI", name: "Bulls", city: "Chicago", abbreviation: "CHI", sport: .nba, conference: "Eastern", division: "Central", primaryColor: "CE1141", secondaryColor: "000000"),
        SportsTeam(id: "CLE", name: "Cavaliers", city: "Cleveland", abbreviation: "CLE", sport: .nba, conference: "Eastern", division: "Central", primaryColor: "860038", secondaryColor: "FDBB30"),
        SportsTeam(id: "DET", name: "Pistons", city: "Detroit", abbreviation: "DET", sport: .nba, conference: "Eastern", division: "Central", primaryColor: "C8102E", secondaryColor: "1D42BA"),
        SportsTeam(id: "IND", name: "Pacers", city: "Indiana", abbreviation: "IND", sport: .nba, conference: "Eastern", division: "Central", primaryColor: "002D62", secondaryColor: "FDBB30"),
        SportsTeam(id: "MIL", name: "Bucks", city: "Milwaukee", abbreviation: "MIL", sport: .nba, conference: "Eastern", division: "Central", primaryColor: "00471B", secondaryColor: "EEE1C6"),
        
        // Eastern - Southeast
        SportsTeam(id: "ATL", name: "Hawks", city: "Atlanta", abbreviation: "ATL", sport: .nba, conference: "Eastern", division: "Southeast", primaryColor: "E03A3E", secondaryColor: "C1D32F"),
        SportsTeam(id: "CHA", name: "Hornets", city: "Charlotte", abbreviation: "CHA", sport: .nba, conference: "Eastern", division: "Southeast", primaryColor: "1D1160", secondaryColor: "00788C"),
        SportsTeam(id: "MIA", name: "Heat", city: "Miami", abbreviation: "MIA", sport: .nba, conference: "Eastern", division: "Southeast", primaryColor: "98002E", secondaryColor: "F9A01B"),
        SportsTeam(id: "ORL", name: "Magic", city: "Orlando", abbreviation: "ORL", sport: .nba, conference: "Eastern", division: "Southeast", primaryColor: "0077C0", secondaryColor: "C4CED4"),
        SportsTeam(id: "WAS", name: "Wizards", city: "Washington", abbreviation: "WAS", sport: .nba, conference: "Eastern", division: "Southeast", primaryColor: "002B5C", secondaryColor: "E31837"),
        
        // Western - Northwest
        SportsTeam(id: "DEN", name: "Nuggets", city: "Denver", abbreviation: "DEN", sport: .nba, conference: "Western", division: "Northwest", primaryColor: "0E2240", secondaryColor: "FEC524"),
        SportsTeam(id: "MIN", name: "Timberwolves", city: "Minnesota", abbreviation: "MIN", sport: .nba, conference: "Western", division: "Northwest", primaryColor: "0C2340", secondaryColor: "236192"),
        SportsTeam(id: "OKC", name: "Thunder", city: "Oklahoma City", abbreviation: "OKC", sport: .nba, conference: "Western", division: "Northwest", primaryColor: "007AC1", secondaryColor: "EF3B24"),
        SportsTeam(id: "POR", name: "Trail Blazers", city: "Portland", abbreviation: "POR", sport: .nba, conference: "Western", division: "Northwest", primaryColor: "E03A3E", secondaryColor: "000000"),
        SportsTeam(id: "UTA", name: "Jazz", city: "Utah", abbreviation: "UTA", sport: .nba, conference: "Western", division: "Northwest", primaryColor: "002B5C", secondaryColor: "F9A01B"),
        
        // Western - Pacific
        SportsTeam(id: "GSW", name: "Warriors", city: "Golden State", abbreviation: "GSW", sport: .nba, conference: "Western", division: "Pacific", primaryColor: "1D428A", secondaryColor: "FFC72C"),
        SportsTeam(id: "LAC", name: "Clippers", city: "LA", abbreviation: "LAC", sport: .nba, conference: "Western", division: "Pacific", primaryColor: "C8102E", secondaryColor: "1D428A"),
        SportsTeam(id: "LAL", name: "Lakers", city: "Los Angeles", abbreviation: "LAL", sport: .nba, conference: "Western", division: "Pacific", primaryColor: "552583", secondaryColor: "FDB927"),
        SportsTeam(id: "PHX", name: "Suns", city: "Phoenix", abbreviation: "PHX", sport: .nba, conference: "Western", division: "Pacific", primaryColor: "1D1160", secondaryColor: "E56020"),
        SportsTeam(id: "SAC", name: "Kings", city: "Sacramento", abbreviation: "SAC", sport: .nba, conference: "Western", division: "Pacific", primaryColor: "5A2D81", secondaryColor: "63727A"),
        
        // Western - Southwest
        SportsTeam(id: "DAL", name: "Mavericks", city: "Dallas", abbreviation: "DAL", sport: .nba, conference: "Western", division: "Southwest", primaryColor: "00538C", secondaryColor: "002B5E"),
        SportsTeam(id: "HOU", name: "Rockets", city: "Houston", abbreviation: "HOU", sport: .nba, conference: "Western", division: "Southwest", primaryColor: "CE1141", secondaryColor: "000000"),
        SportsTeam(id: "MEM", name: "Grizzlies", city: "Memphis", abbreviation: "MEM", sport: .nba, conference: "Western", division: "Southwest", primaryColor: "5D76A9", secondaryColor: "12173F"),
        SportsTeam(id: "NOP", name: "Pelicans", city: "New Orleans", abbreviation: "NOP", sport: .nba, conference: "Western", division: "Southwest", primaryColor: "0C2340", secondaryColor: "C8102E"),
        SportsTeam(id: "SAS", name: "Spurs", city: "San Antonio", abbreviation: "SAS", sport: .nba, conference: "Western", division: "Southwest", primaryColor: "C4CED4", secondaryColor: "000000")
    ]
}

// MARK: - NFL Data

enum NFLData {
    static let allTeams: [SportsTeam] = [
        // AFC East
        SportsTeam(id: "BUF", name: "Bills", city: "Buffalo", abbreviation: "BUF", sport: .nfl, conference: "AFC", division: "East", primaryColor: "00338D", secondaryColor: "C60C30"),
        SportsTeam(id: "MIA", name: "Dolphins", city: "Miami", abbreviation: "MIA", sport: .nfl, conference: "AFC", division: "East", primaryColor: "008E97", secondaryColor: "FC4C02"),
        SportsTeam(id: "NE", name: "Patriots", city: "New England", abbreviation: "NE", sport: .nfl, conference: "AFC", division: "East", primaryColor: "002244", secondaryColor: "C60C30"),
        SportsTeam(id: "NYJ", name: "Jets", city: "New York", abbreviation: "NYJ", sport: .nfl, conference: "AFC", division: "East", primaryColor: "125740", secondaryColor: "FFFFFF"),
        
        // AFC North
        SportsTeam(id: "BAL", name: "Ravens", city: "Baltimore", abbreviation: "BAL", sport: .nfl, conference: "AFC", division: "North", primaryColor: "241773", secondaryColor: "000000"),
        SportsTeam(id: "CIN", name: "Bengals", city: "Cincinnati", abbreviation: "CIN", sport: .nfl, conference: "AFC", division: "North", primaryColor: "FB4F14", secondaryColor: "000000"),
        SportsTeam(id: "CLE", name: "Browns", city: "Cleveland", abbreviation: "CLE", sport: .nfl, conference: "AFC", division: "North", primaryColor: "311D00", secondaryColor: "FF3C00"),
        SportsTeam(id: "PIT", name: "Steelers", city: "Pittsburgh", abbreviation: "PIT", sport: .nfl, conference: "AFC", division: "North", primaryColor: "FFB612", secondaryColor: "101820"),
        
        // AFC South
        SportsTeam(id: "HOU", name: "Texans", city: "Houston", abbreviation: "HOU", sport: .nfl, conference: "AFC", division: "South", primaryColor: "03202F", secondaryColor: "A71930"),
        SportsTeam(id: "IND", name: "Colts", city: "Indianapolis", abbreviation: "IND", sport: .nfl, conference: "AFC", division: "South", primaryColor: "002C5F", secondaryColor: "A2AAAD"),
        SportsTeam(id: "JAX", name: "Jaguars", city: "Jacksonville", abbreviation: "JAX", sport: .nfl, conference: "AFC", division: "South", primaryColor: "006778", secondaryColor: "D7A22A"),
        SportsTeam(id: "TEN", name: "Titans", city: "Tennessee", abbreviation: "TEN", sport: .nfl, conference: "AFC", division: "South", primaryColor: "0C2340", secondaryColor: "4B92DB"),
        
        // AFC West
        SportsTeam(id: "DEN", name: "Broncos", city: "Denver", abbreviation: "DEN", sport: .nfl, conference: "AFC", division: "West", primaryColor: "FB4F14", secondaryColor: "002244"),
        SportsTeam(id: "KC", name: "Chiefs", city: "Kansas City", abbreviation: "KC", sport: .nfl, conference: "AFC", division: "West", primaryColor: "E31837", secondaryColor: "FFB81C"),
        SportsTeam(id: "LV", name: "Raiders", city: "Las Vegas", abbreviation: "LV", sport: .nfl, conference: "AFC", division: "West", primaryColor: "000000", secondaryColor: "A5ACAF"),
        SportsTeam(id: "LAC", name: "Chargers", city: "Los Angeles", abbreviation: "LAC", sport: .nfl, conference: "AFC", division: "West", primaryColor: "0080C6", secondaryColor: "FFC20E"),
        
        // NFC East
        SportsTeam(id: "DAL", name: "Cowboys", city: "Dallas", abbreviation: "DAL", sport: .nfl, conference: "NFC", division: "East", primaryColor: "003594", secondaryColor: "869397"),
        SportsTeam(id: "NYG", name: "Giants", city: "New York", abbreviation: "NYG", sport: .nfl, conference: "NFC", division: "East", primaryColor: "0B2265", secondaryColor: "A71930"),
        SportsTeam(id: "PHI", name: "Eagles", city: "Philadelphia", abbreviation: "PHI", sport: .nfl, conference: "NFC", division: "East", primaryColor: "004C54", secondaryColor: "A5ACAF"),
        SportsTeam(id: "WAS", name: "Commanders", city: "Washington", abbreviation: "WAS", sport: .nfl, conference: "NFC", division: "East", primaryColor: "5A1414", secondaryColor: "FFB612"),
        
        // NFC North
        SportsTeam(id: "CHI", name: "Bears", city: "Chicago", abbreviation: "CHI", sport: .nfl, conference: "NFC", division: "North", primaryColor: "0B2265", secondaryColor: "C83803"),
        SportsTeam(id: "DET", name: "Lions", city: "Detroit", abbreviation: "DET", sport: .nfl, conference: "NFC", division: "North", primaryColor: "0076B6", secondaryColor: "B0B7BC"),
        SportsTeam(id: "GB", name: "Packers", city: "Green Bay", abbreviation: "GB", sport: .nfl, conference: "NFC", division: "North", primaryColor: "203731", secondaryColor: "FFB611"),
        SportsTeam(id: "MIN", name: "Vikings", city: "Minnesota", abbreviation: "MIN", sport: .nfl, conference: "NFC", division: "North", primaryColor: "4F2683", secondaryColor: "FFC62F"),
        
        // NFC South
        SportsTeam(id: "ATL", name: "Falcons", city: "Atlanta", abbreviation: "ATL", sport: .nfl, conference: "NFC", division: "South", primaryColor: "A71930", secondaryColor: "000000"),
        SportsTeam(id: "CAR", name: "Panthers", city: "Carolina", abbreviation: "CAR", sport: .nfl, conference: "NFC", division: "South", primaryColor: "0085CA", secondaryColor: "101820"),
        SportsTeam(id: "NO", name: "Saints", city: "New Orleans", abbreviation: "NO", sport: .nfl, conference: "NFC", division: "South", primaryColor: "D3BC8D", secondaryColor: "101820"),
        SportsTeam(id: "TB", name: "Buccaneers", city: "Tampa Bay", abbreviation: "TB", sport: .nfl, conference: "NFC", division: "South", primaryColor: "D50A0A", secondaryColor: "34302B"),
        
        // NFC West
        SportsTeam(id: "ARI", name: "Cardinals", city: "Arizona", abbreviation: "ARI", sport: .nfl, conference: "NFC", division: "West", primaryColor: "97233F", secondaryColor: "000000"),
        SportsTeam(id: "LAR", name: "Rams", city: "Los Angeles", abbreviation: "LAR", sport: .nfl, conference: "NFC", division: "West", primaryColor: "003594", secondaryColor: "FFA300"),
        SportsTeam(id: "SF", name: "49ers", city: "San Francisco", abbreviation: "SF", sport: .nfl, conference: "NFC", division: "West", primaryColor: "AA0000", secondaryColor: "B3995D"),
        SportsTeam(id: "SEA", name: "Seahawks", city: "Seattle", abbreviation: "SEA", sport: .nfl, conference: "NFC", division: "West", primaryColor: "002244", secondaryColor: "69BE28")
    ]
}

// MARK: - Roast Intensity

enum RoastIntensity: String, Codable, CaseIterable {
    case trashTalk = "TRASH TALK"
    case dunkedOn = "DUNKED ON"
    case posterized = "POSTERIZED"
    
    var description: String {
        switch self {
        case .trashTalk:
            return "Light banter"
        case .dunkedOn:
            return "Medium heat"
        case .posterized:
            return "Maximum destruction"
        }
    }
    
    var color: Color {
        switch self {
        case .trashTalk:
            return Color(hex: "FFCC00") // Yellow
        case .dunkedOn:
            return Color(hex: "FF8C00") // Amber
        case .posterized:
            return Color(hex: "FF4500") // Savage Orange
        }
    }
    
    var contentColor: Color {
        switch self {
        case .trashTalk, .dunkedOn:
            return .black
        case .posterized:
            return .white
        }
    }
}

// MARK: - User Sports Preferences

struct UserSportsPreferences: Codable {
    var selectedSport: SportType = .nba
    let myTeam: SportsTeam
    let rivalTeams: [SportsTeam] // Max 3
    let intensity: RoastIntensity
    
    init(selectedSport: SportType = .nba, myTeam: SportsTeam, rivalTeams: [SportsTeam], intensity: RoastIntensity) {
        self.selectedSport = selectedSport
        self.myTeam = myTeam
        self.rivalTeams = Array(rivalTeams.prefix(3)) // Enforce max 3
        self.intensity = intensity
    }
}
