import 'package:appwrite/appwrite.dart';

void main() async {
  final client = Client();
  final tablesDb = TablesDB(client);
  
  final rowList = await tablesDb.listRows(databaseId: 'x', tableId: 'y');
  if (rowList.rows.isNotEmpty) {
    final row = rowList.rows.first;
    // ignore: unused_local_variable
    var id = row.$id;
    // ignore: unused_local_variable
    var createdAt = row.$createdAt;
  }
}
