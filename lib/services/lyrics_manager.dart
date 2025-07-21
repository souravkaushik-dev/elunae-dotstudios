/*🔧 Under Design · DotStudios*/

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class LyricsManager {
  Future<String?> fetchLyrics(String artistName, String title) async {
    title = title.replaceAll('Lyrics', '').replaceAll('Karaoke', '');

    final lyricsFromGoogle = await _fetchLyricsFromGoogle(artistName, title);
    if (lyricsFromGoogle != null) {
      return lyricsFromGoogle;
    }

    final lyricsFromParolesNet = await _fetchLyricsFromParolesNet(
      artistName.split(',')[0],
      title,
    );
    if (lyricsFromParolesNet != null) {
      return lyricsFromParolesNet;
    }

    final lyricsFromLyricsMania1 = await _fetchLyricsFromLyricsMania1(
      artistName,
      title,
    );
    return lyricsFromLyricsMania1;
  }

  Future<String?> _fetchLyricsFromGoogle(
    String artistName,
    String title,
  ) async {
    const url =
        'https://www.google.com/search?client=safari&rls=en&ie=UTF-8&oe=UTF-8&q=';
    const delimiter1 =
        '</div></div></div></div><div class="hwc"><div class="BNeawe tAd8D AP7Wnd"><div><div class="BNeawe tAd8D AP7Wnd">';
    const delimiter2 =
        '</div></div></div></div></div><div><span class="hwc"><div class="BNeawe uEec3 AP7Wnd">';

    try {
      final res = await http
          .get(Uri.parse(Uri.encodeFull('$url$artistName - $title lyrics')))
          .timeout(const Duration(seconds: 10));
      final body = res.body;
      final lyricsRes = body.substring(
        body.indexOf(delimiter1) + delimiter1.length,
        body.lastIndexOf(delimiter2),
      );
      if (lyricsRes.contains('<meta charset="UTF-8">')) return null;
      if (lyricsRes.contains('please enable javascript on your web browser'))
        return null;
      if (lyricsRes.contains('Error 500 (Server Error)')) return null;
      if (lyricsRes.contains(
        'systems have detected unusual traffic from your computer network',
      ))
        return null;
      return lyricsRes;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _fetchLyricsFromParolesNet(
    String artistName,
    String title,
  ) async {
    final uri = Uri.parse(
      'https://www.paroles.net/${_lyricsUrl(artistName)}/paroles-${_lyricsUrl(title)}',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);
      final songTextElements = document.querySelectorAll('.song-text');

      if (songTextElements.isNotEmpty) {
        final lyricsLines = songTextElements.first.text.split('\n');
        if (lyricsLines.length > 1) {
          lyricsLines.removeAt(0);

          final finalLyrics = addCopyright(
            lyricsLines.join('\n'),
            'www.paroles.net',
          );
          return _removeSpaces(finalLyrics);
        }
      }
    }

    return null;
  }

  Future<String?> _fetchLyricsFromLyricsMania1(
    String artistName,
    String title,
  ) async {
    final uri = Uri.parse(
      'https://www.lyricsmania.com/${_lyricsManiaUrl(title)}_lyrics_${_lyricsManiaUrl(artistName)}.html',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);
      final lyricsBodyElements = document.querySelectorAll('.lyrics-body');

      if (lyricsBodyElements.isNotEmpty) {
        return addCopyright(
          lyricsBodyElements.first.text,
          'www.lyricsmania.com',
        );
      }
    }

    return null;
  }

  String _lyricsUrl(String input) {
    var result = input.replaceAll(' ', '-').toLowerCase();
    if (result.isNotEmpty && result.endsWith('-')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  String _lyricsManiaUrl(String input) {
    var result = input.replaceAll(' ', '_').toLowerCase();
    if (result.isNotEmpty && result.startsWith('_')) {
      result = result.substring(1);
    }
    if (result.isNotEmpty && result.endsWith('_')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  String _removeSpaces(String input) {
    return input.replaceAll('  ', '');
  }

  String addCopyright(String input, String copyright) {
    return '$input\n\n© $copyright';
  }
}
