import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart';

//todo: change statefulwidget to stateless with streams

class GameRoute extends StatelessWidget {
  Socket socket;
  final data;
  final name;

  GameRoute({this.socket, this.data, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal.shade50,
        body: _GameScreen(
          socket: socket,
          data: data,
          name: name,
        ));
  }
}

class _GameScreen extends StatefulWidget {
  final Socket socket;
  final data;
  final name;

  /// data: [*num*, 'opponent_name']
  /// *num*: 1 or 2, depending on whether I am 'x' or 'o' respectfully
  _GameScreen({this.socket, this.data, this.name});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  final _borderColor = Colors.cyan.shade600;
  final _borderWidth = 2.0;

  bool _myMove;
  bool _timerRunning = true;
  int _timer = 20;
  bool _waiting = false;
  int _end;

  final List<List<int>> _map = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ];

  @override
  void initState() {
    _myMove = widget.data[0] == 1;
    _timerRunner();

    widget.socket.on('gameError', (data) {
      if (_end == null) {
        setState(() {
          _waiting = false;
        });
        () async {
          Future.delayed(
              Duration.zero,
              () => Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(milliseconds: 400),
                    content: Text('Error. $data'),
                    backgroundColor: Colors.cyan.shade600,
                  )));
        }();
      }
    });

    widget.socket.on('move', (data) {
      move(data);
    });
    widget.socket.on('gameEnd', (data) {
      gameEnd(data);
    });

    super.initState();
  }

  @override
  void dispose() {
//    widget.socket = null;
    super.dispose();
  }

  void move(data) {
    print('New move!');
    if (_end == null)
      setState(() {
        _myMove = !_myMove;
        _map[data[2]][data[1]] = data[0];
        _timer = 20;
        _waiting = false;
      });
  }

  void gameEnd(data) {
    print('Game has ended!');
    if (_end == null)
      setState(() {
        _end = data;
        _waiting = false;
      });
  }

  void _timerRunner() async {
    if (_timer > 0 && _timerRunning && _end == null) setState(() => _timer--);
    Future.delayed(Duration(seconds: 1), _timerRunner);
  }

  @override
  Widget build(BuildContext context) {
    Widget o = Padding(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        size: const Size(6, 6),
        painter: _CirclePainter(
            (widget.data[0] == 2 && _myMove || widget.data[0] == 1 && !_myMove)
                ? Colors.cyan[600]
                : Colors.grey[900]),
      ),
    );

    Widget x = Padding(
      padding: const EdgeInsets.all(6),
      child: CustomPaint(
        size: const Size(12, 12),
        painter: _IntersectPainter(
            (widget.data[0] == 1 && _myMove || widget.data[0] == 2 && !_myMove)
                ? Colors.cyan[600]
                : Colors.grey[900]),
      ),
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                width: 120,
                child: Text(
                  widget.name,
                  style: GoogleFonts.andika(
                      color: _myMove ? Colors.cyan[600] : Colors.grey[900],
                      fontSize: 24),
                ),
              ),
              (widget.data[0] == 1) ? x : o,
              Text(
                ' vs ',
                style: GoogleFonts.andika(
                    color: Colors.grey[900],
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              (widget.data[0] == 1) ? o : x,
              Container(
                width: 120,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data[1],
                  style: GoogleFonts.andika(
                      color: !_myMove ? Colors.cyan[600] : Colors.grey[900],
                      fontSize: 24),
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          Text(
            '${_myMove ? widget.name : widget.data[1]}\'s move',
            style: GoogleFonts.andika(fontSize: 18),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(4)),
            child: Text(
              _timer.toString(),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    cell(
                        context,
                        0,
                        0,
                        Border(
                          right: BorderSide(
                              color: _borderColor, width: _borderWidth),
                          bottom: BorderSide(
                              color: _borderColor, width: _borderWidth),
                        )),
                    cell(
                        context,
                        1,
                        0,
                        Border(
                          right: BorderSide(
                              color: _borderColor, width: _borderWidth),
                          bottom: BorderSide(
                              color: _borderColor, width: _borderWidth),
                        )),
                    cell(
                        context,
                        2,
                        0,
                        Border(
                          bottom: BorderSide(
                              color: _borderColor, width: _borderWidth),
                        )),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    cell(
                        context,
                        0,
                        1,
                        Border(
                          right: BorderSide(
                              color: _borderColor, width: _borderWidth),
                          bottom: BorderSide(
                              color: _borderColor, width: _borderWidth),
                        )),
                    cell(
                        context,
                        1,
                        1,
                        Border(
                          right: BorderSide(
                              color: _borderColor, width: _borderWidth),
                          bottom: BorderSide(
                              color: _borderColor, width: _borderWidth),
                        )),
                    cell(
                        context,
                        2,
                        1,
                        Border(
                            bottom: BorderSide(
                                color: _borderColor, width: _borderWidth))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    cell(
                        context,
                        0,
                        2,
                        Border(
                            right: BorderSide(
                                color: _borderColor, width: _borderWidth))),
                    cell(
                        context,
                        1,
                        2,
                        Border(
                            right: BorderSide(
                                color: _borderColor, width: _borderWidth))),
                    cell(context, 2, 2, Border()),
                  ],
                )
              ],
            ),
          ),
          if (_end != null)
            SizedBox(
              height: 64,
            ),
          if (_end != null)
            Text(
              '${_end == 0 ? 'no one' : (_end == widget.data[0] ? widget.name : widget.data[1])} has won!',
              style: GoogleFonts.andika(fontSize: 22),
            ),
          if (_end != null)
            SizedBox(
              height: 16,
            ),
          if (_end != null)
            Material(
              borderRadius: BorderRadius.circular(12),
              color: Colors.cyan[200],
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 320,
                  height: 50,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'close',
                        style: GoogleFonts.comfortaa(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Icon(
                        MdiIcons.close,
                        size: 22,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget cell(var context, var cx, var cy, var border, [var name = '']) {
    var value = _map[cy][cx];

    Widget child;

    switch (value) {
      case 1:
        child = _x();
        break;

      case 2:
        child = _o();
        break;

      default:
        child = Container();
        break;
    }

    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(border: border),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          child: child,
          onTap: () {
            if (_waiting) {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(milliseconds: 400),
                content: Text('Error. Waiting for the response from server'),
                backgroundColor: Colors.cyan.shade600,
              ));
              return;
            }

            if (_end != null) {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(milliseconds: 400),
                content: Text('Error. Game has already ended'),
                backgroundColor: Colors.cyan.shade600,
              ));
              return;
            }

            if (!_myMove) {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(milliseconds: 400),
                content: Text('Error. Not your move'),
                backgroundColor: Colors.cyan.shade600,
              ));
              return;
            }

            _waiting = true;
            widget.socket.emit('makeMove', [cx, cy]);
            print('my move');
          },
        ),
      ),
    );
  }

  Widget _o() => Padding(
        padding: const EdgeInsets.all(22),
        child: CustomPaint(
          painter: _CirclePainter(Colors.black),
          size: Size(200, 200),
        ),
      );

  Widget _x() => Padding(
        padding: const EdgeInsets.all(18),
        child: CustomPaint(
          painter: _IntersectPainter(Colors.black),
          size: Size(200, 200),
        ),
      );
}

class _CirclePainter extends CustomPainter {
  Color _color;

  _CirclePainter(this._color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = _color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.height, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _IntersectPainter extends CustomPainter {
  Color _color;

  _IntersectPainter(this._color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = _color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
