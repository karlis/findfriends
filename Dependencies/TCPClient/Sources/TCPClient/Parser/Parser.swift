import Parsing

struct MessageParser {
  func parse(input: String) -> Message? {
    Parser.shared.parse(input: input)
  }
}

class Parser {
  static let shared = Parser()

  func parse(input: String) -> Message? {
    if let users = usersParser.parse(input), !users.isEmpty {
      return .userlist(users)
    }
    if let updates = updatesParser.parse(input), !updates.isEmpty {
      return .update(updates)
    }
    return nil
  }

  // MARK: - Parsers

  private lazy var idParser = Int.parser()
  private lazy var userDetailsParser = Prefix<Substring> { $0 != ","}
    .skip(StartsWith(","))
    .take(Prefix { $0 != ","})

  private lazy var locationParser = Double.parser()
    .skip(StartsWith(","))
    .take(Double.parser())
    .map {
      Location(latitude: $0.0, longitude: $0.1)
    }

  private lazy var userParser = idParser
    .skip(StartsWith(","))
    .take(userDetailsParser)
    .skip(StartsWith(","))
    .take(locationParser)
    .map {
      User(id: String($0.0), name: String($0.1.0), image: String($0.1.1), location: $0.2)
    }

  private lazy var usersParser = StartsWith<Substring>("USERLIST")
    .skip(StartsWith(" "))
    .take(Many(userParser, separator: StartsWith(";")))
    .skip(StartsWith(";"))

  private lazy var updateParser = StartsWith<Substring>("UPDATE")
    .skip(StartsWith(" "))
    .take(idParser)
    .skip(StartsWith(","))
    .take(locationParser)
    .map {
      UserUpdate(id: String($0.0), location: $0.1)
    }

  private lazy var updatesParser = Many(updateParser, separator: StartsWith("\n"))
}



// MARK: - Test input

//var userlistInput = "USERLIST 101,Jānis Bērziņš,https://i4.ifrype.com/profile/000/324/v1559116100/ngm_324.jpg,56.9495677035,24.1064071655;102,Pēteris Zariņš,https://i7.ifrype.com/profile/666/047/v1572553757/ngm_4666047.jpg,56.9503693176,24.1084241867;"
//
//var updatesInput = """
//  UPDATE 101,56.9495677035,24.1064071655
//  UPDATE 102,56.9509836817,24.1108596325
//  """

