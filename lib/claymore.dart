library claymore;
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import 'package:mustache4dart/mustache4dart.dart' as mustache;

Map<String, String> partials;

class Claymore {
  Map<String, String> _partials = new Map<String, String>();
  String _layoutContents = "";

  Claymore(String base) {
    _initTemplate(base);
    _initPartials(base);
  }

  _initTemplate(String base) async {
    var path = "$base/layout.hbs";
    var file = new File(path);
    _layoutContents = await file.readAsString();
  }

  _initPartials(String base) async{
    List<FileSystemEntity> partials = await new Directory("$base/partials").listSync();
    for (FileSystemEntity fs in partials) {
      bool isFile = await FileSystemEntity.isFile(fs.path);
      if (isFile) {
        File f = new File(fs.path);
        String contents = await f.readAsString();
        _partials[basename(f.path).replaceAll(".hbs", "")] = contents;
        print(_partials[basename(f.path).replaceAll(".hbs", "")]);
      }
    }
  }

  Future<String> render(String partialName, Map vars) async{
    return mustache.render(_layoutContents, vars, partial: _partialProvider);
  }

  String _partialProvider(String partialName) {
    return _partials[partialName];
  }

}