import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';

import 'game.dart';

//todo: proper documentation
//todo: tests
void main() {
  runApp(MaterialApp(home: InitScreen()));
}

//todo: change statefulwidget to stateless with streams
class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int _check = 1;
  TextEditingController _nameController;
  bool _loading = false;
  Socket _socket;
  var _uOnline = 0;

  String _nameSet = null;

  @override
  void initState() {
    _nameController = TextEditingController();

    var url = 'https://tic-tac-toe-server.marchello.cf';

    _socket = io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    print('connecting...');

    _socket.connect();

    _socket.on('connect', (_) {
      print('connected');

      _socket.on('getPlayers', (data) {
        print('Amount of players was received');
        setState(() => _uOnline = data);
      });

      _socket.on('gameFound', (data) {
        print('game was found: $data');

        setState(() {
          _loading = false;
        });
        var gameScreen =
            GameRoute(data: data, socket: _socket, name: _nameController.text);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => gameScreen));
      });

      _socket.on('disconnect', (_) {
        print('disconnected');
        setState(() => _uOnline = 0);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

//todo: remove spacers, use alignment
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.teal.shade50,
        body: Center(
          child: Container(
            width: 480,
            height: 1600,
            child: Column(
              children: <Widget>[
                Spacer(),
                Text(
                  'Tic-Tac-Toe',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 24),
                ),
                Text(
                  'online: $_uOnline',
                  style: GoogleFonts.andika(
                      fontWeight: FontWeight.w500, fontSize: 18),
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  width: 240,
                  child: TextField(
                    controller: _nameController,
                    style: GoogleFonts.play(
                        fontSize: 20, color: Colors.cyan.shade800),
                    textAlign: TextAlign.center,
                    cursorColor: Colors.cyan,
                    decoration: InputDecoration(
                        hintText: 'Type your name',
                        hintStyle: GoogleFonts.play(fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.cyan.shade300, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              BorderSide(color: Colors.cyan.shade500, width: 3),
                        )),
                  ),
                ),
                SizedBox(height: 40),
                Builder(
                  builder: (context) => Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.cyan[200],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (_nameController.text == '')
                          Scaffold.of(context).showSnackBar(SnackBar(
                            duration: Duration(milliseconds: 400),
                            content: Text('Error. Type your name'),
                            backgroundColor: Colors.cyan.shade600,
                          ));
                        else if (_check == 0)
                          Scaffold.of(context).showSnackBar(SnackBar(
                            duration: Duration(milliseconds: 400),
                            content: Text('Error. Select O or X'),
                            backgroundColor: Colors.cyan.shade600,
                          ));
                        else if (!_loading) {
                          setState(() {
                            _loading = true;
                          });
                          if (_nameSet == null ||
                              _nameSet != _nameController.text) {
                            _socket.emit('setName', _nameController.text);
                            _nameSet = _nameController.text;
                          }
                          _socket.emit('findGame');
                        } else {
                          setState(() {
                            _loading = false;
                          });
                          _socket.emit('stopFindGame');
                        }
                      },
                      child: Container(
                        width: 320,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _loading ? 'looking for a game...' : 'continue',
                              style: GoogleFonts.comfortaa(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            _loading
                                ? Container(
                                    margin: EdgeInsets.only(left: 6),
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white)),
                                  )
                                : Icon(
                                    MdiIcons.arrowRight,
                                    size: 22,
                                    color: Colors.white,
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(MdiIcons.github),
                  color: Colors.cyan.shade400,
                  onPressed: () async {
                    final url = 'https://google.com';
                    if (await canLaunch(url)) await launch(url);
                  },
                ),
                SizedBox(height: 24)
              ],
            ),
          ),
        ),
      );
}
