import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

final ThemeData iceaTheme = ThemeData(
  primaryColor: Color(0xFF002D72),
  scaffoldBackgroundColor: Color(0xFFE6F0FA),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF002D72),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  iconTheme: IconThemeData(color: Color(0xFFFFD700)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFD700),
      foregroundColor: Colors.black,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  listTileTheme: ListTileThemeData(
    tileColor: Color(0xFF1A4CA0),
    textColor: Colors.white,
    iconColor: Color(0xFFFFD700),
  ),
);

void main() =>
    runApp(
      MaterialApp(
        locale: Locale('pt', 'BR'),
        supportedLocales: [Locale('pt', 'BR')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'ICEA App',
        theme: iceaTheme,
        home: Main(),
      ),
    );

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final Color azulCeu = Color(0xFFE6F0FA);

  final List<IconData> icons = [
    Icons.church,
    Icons.speaker_notes,
    Icons.library_books,
    Icons.check_circle,
    Icons.person,
    Icons.queue_music,
    Icons.calendar_month,
  ];

  final List<String> titles = [
    'Igrejas',
    'Estatuto',
    'Regimento',
    'Código de Ética',
    'Credenciais',
    'Hinário',
    'Agenda',
  ];

  final List<Widget> screens = [
    IgrejasScreen(),
    EstatutoScreen(),
    RegimentoScreen(),
    CodigoEticaScreen(),
    CredenciaisScreen(),
    HinarioScreen(),
    AgendaScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _animationController.forward() : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double radius = 160;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002D72), Color(0xFFE6F0FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Ícones circulares com IgnorePointer
                  IgnorePointer(
                    ignoring: !isOpen,
                    child: Stack(
                      children: [
                        for (int i = 0; i < icons.length; i++)
                          Positioned(
                            left:
                            MediaQuery
                                .of(context)
                                .size
                                .width / 2 +
                                radius *
                                    _animation.value *
                                    cos(2 * pi * i / icons.length) -
                                35,
                            top:
                            MediaQuery
                                .of(context)
                                .size
                                .height / 2 +
                                radius *
                                    _animation.value *
                                    sin(2 * pi * i / icons.length) -
                                35,
                            child: GestureDetector(
                              onTap: () {
                                print('Clicou em ${titles[i]}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => screens[i],
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(icons[i], size: 60, color: Colors.white),
                                  SizedBox(height: 1),
                                  Text(
                                    titles[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Ícone central (sempre por cima e clicável)
                  GestureDetector(
                    onTap: toggleMenu,
                    child: CircleAvatar(
                      radius: 80,
                      child: Image.asset(
                        'assets/images/logo_icea.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class EventoAgenda {
  final String titulo;
  final String descricao;
  final String data;
  final String local;

  EventoAgenda({
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.local,
  });
}

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  final Map<DateTime, List<String>> eventos = {
    DateTime(2025, 10, 5): ['Santa Ceia'],
    DateTime(2025, 10, 11): ['Dia da Criança - EBD'],
    DateTime(2025, 10, 18): ['Ensaio Geral dos Jovens para o XIV Conai'],
    DateTime(2025, 10, 25): ['Conferência de Homens na Congregação do Jardim das Américas'],
    DateTime(2025, 10, 26): ['Conferência de Homens na Congregação do Jardim das Américas'],
    DateTime(2025, 11, 2): ['Santa Ceia'],
    DateTime(2025, 11, 29): ['XIV Conai Jovem'],
    DateTime(2025, 11, 30): ['XIV Conai Jovem'],
    DateTime(2025, 12, 3): ['Abertura da Campanha da Colheita'],
    DateTime(2025, 12, 7): ['Santa Ceia'],
    DateTime(2025, 12, 14): [
      'Encerramento Anual do Departamento de Jovens - Sede',
      'Reunião do Conselho de Obreiros',
    ],
    DateTime(2025, 12, 21): ['Cantata de Natal'],
    DateTime(2025, 12, 22): ['Início do Recesso Natalino em Família'],
    DateTime(2025, 12, 28): ['Reinício das Atividades - Culto normal em todas as igrejas'],
    DateTime(2025, 12, 31): ['Confraternização Iceana'],
  };

  final List<DateTime> feriados = [
    DateTime(2025, 1, 1),
    DateTime(2025, 4, 21),
    DateTime(2025, 5, 1),
    DateTime(2025, 7, 26),
    DateTime(2025, 7, 31),
    DateTime(2025, 9, 7),
    DateTime(2025, 10, 12),
    DateTime(2025, 11, 2),
    DateTime(2025, 11, 15),
    DateTime(2025, 12, 25),
    DateTime(2025, 3, 4),
    DateTime(2025, 4, 18),
    DateTime(2025, 4, 20),
    DateTime(2025, 6, 19),
  ];

  List<String> _getEventosDoDia(DateTime day) {
    return eventos[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<MapEntry<DateTime, List<String>>> _getEventosDoMes(DateTime mes) {
    return eventos.entries
        .where((entry) => entry.key.year == mes.year && entry.key.month == mes.month)
        .toList();
  }

  bool _isFeriado(DateTime day) {
    return feriados.any((f) => f.year == day.year && f.month == day.month && f.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('AGENDA')),
      backgroundColor: azulIntermediario,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: 400,
                  child: TableCalendar(
                    locale: 'pt_BR',
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: azulClaro,
                      ),
                      leftChevronIcon: Icon(Icons.arrow_circle_left, color: dourado),
                      rightChevronIcon: Icon(Icons.arrow_circle_right, color: dourado),
                    ),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventosDoDia,
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: azulClaro),
                      weekendTextStyle: TextStyle(color: azulClaro),
                      outsideTextStyle: TextStyle(color: Colors.grey),
                      todayDecoration: BoxDecoration(
                        color: dourado,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: azulProfundo,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: dourado,
                        shape: BoxShape.circle,
                      ),
                      holidayDecoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                      markerSize: 10,
                      markerMargin: EdgeInsets.zero,
                    ),
                    holidayPredicate: _isFeriado,
                    calendarBuilders: CalendarBuilders(
                      holidayBuilder: (context, day, focusDay) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.celebration, size: 16, color: Colors.red),
                            ],
                          ),
                        );
                      },
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: azulClaro,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendStyle: TextStyle(
                        color: dourado,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                Divider(thickness: 1, color: Colors.grey[300]),
                SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    children: _getEventosDoMes(_focusedDay).map((entry) {
                      final dia = entry.key;
                      final lista = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${dia.day}/${dia.month}/${dia.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulClaro,
                              ),
                            ),
                          ),
                          ...lista.map(
                                (evento) => Card(
                              color: azulIntermediario,
                              child: ListTile(
                                leading: Icon(Icons.event, color: dourado),
                                title: Text(
                                  evento,
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                            ),
                          ).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


/*class DetalheAgendaScreen extends StatelessWidget {
  final EventoAgenda evento;

  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  DetalheAgendaScreen({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulIntermediario,
      appBar: AppBar(
        title: Text(evento.titulo),
        backgroundColor: dourado,
        foregroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(evento.data),
            SizedBox(height: 16),
            Text('Local:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(evento.local),
            SizedBox(height: 16),
            Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(evento.descricao),
          ],
        ),
      ),
    );
  }
}*/

class TrechoHino {
  final String tipo;
  final String texto;

  TrechoHino({required this.tipo, required this.texto});
}

class Hino {
  final int codigo;
  final String titulo;
  final List<TrechoHino> trechos;
  final String urlCifraSite;

  Hino({
    required this.codigo,
    required this.titulo,
    required this.trechos,
    required this.urlCifraSite,
  });
}

class HinarioScreen extends StatefulWidget {
  @override
  _HinarioScreenState createState() => _HinarioScreenState();
}

class _HinarioScreenState extends State<HinarioScreen> {
  final TextEditingController _pesquisaController = TextEditingController();
  List<Hino> todosHinos = [];
  List<Hino> hinosFiltrados = [];

  @override
  void initState() {
    super.initState();
    todosHinos = carregarHinos();
    hinosFiltrados = todosHinos;
  }

  void filtrarHinos(String texto) {
    final termo = texto.toLowerCase();
    setState(() {
      hinosFiltrados = todosHinos.where((hino) {
        return hino.titulo.toLowerCase().contains(termo) ||
            hino.codigo.toString().contains(termo) ||
            hino.trechos.any(
                  (trecho) => trecho.texto.toLowerCase().contains(termo),
            );
      }).toList();
    });
  }

  List<Hino> carregarHinos() {
    return [
      Hino(
        codigo: 1,
        titulo: 'A VITÓRIA DESTA IGREJA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vitória desta igreja é a oração\nA vitória desta igreja é a oração,\nJesus atende toda nossa petição,\nDesperta agora tu que dormes, meu irmão\n',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vamos orar, mocidade desta Igreja,\nPara que Jesus ao seu lado sempre esteja,\nJesus em breve vem buscar a sua Igreja,\nE quem não ora está fora da peleja \n',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A igreja quando está em oração,\nO inimigo fica logo sem ação;\nE os que são crentes, seus joelhos estão no chão,\nEle é vencido com o poder da oração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há muitos crentes que não gostam de oração.\nPorque seu erro é olhar pra seu irmão,\nSe os tais soubessem que is to não vem de Jesus,\nSeguiam a Cristo que por nós morreu na cruz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-crista-maranata/a-vitoria-desta-igreja-oracao/',
      ),
      Hino(
        codigo: 2,
        titulo: 'A TEUS PÉS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Teus pés, ó Jesus Cristo,\nTua face buscarei\nEscutando qual Maria,\nAs palavras de amor;\nA Teus pés, ó Jesus Cristo\nMeu passado esquecerei,\nPois tua mão fiel e terna\nTem me salvo do temor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Teus pés, ó Jesus Cristo,\nAcho terna compaixão,\nPara todos meus pesares,\nMeus conflitos, minha dor,\nLivra-me, ó Jesus Cristo,\nDe cuidados, de aflição\nE concede-me constante\nTeu poder consolador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Teus pés, o Jesus Cristo,\nEu desfruto Teu amor,\nEm Teus olhos há doçura\nEm Teu seio proteção;\nDá-me, ó Cristo, a Tua mente.\nDá-me graça e fervor,\nE que o mundo possa sempre\nVer em mim a salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Teus pés, ó Jesus Cristo,\nTenho um gozo divinal!\nA Teus pés encontro abrigo,\nOh! Hondoso Salvador!\nSó em Ti, ó Jesus Cristo,\nHá consolo sem igual,\nPara minh\'alma abatida,\nNeste mundo de horror.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ao-teus-pes/sgpzsgm.html',
      ),
      Hino(
        codigo: 3,
        titulo: 'BUSCANDO A FACE DO SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De madrugada ainda escuro,\nEu já buscava a face do Senhor,\nA Estrela D\'alva ainda brilhava\nQuando eu falava com o Senhor Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Senhor! Senhor!\nTem compaixão de mim\nResolve os meus problemas               (Bis)\nEntrego tudo a Ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Mestre ouvia quando eu dizia\nOs meus problemas para resolver\nCom fé pedia, sim, todo o dia\nPai Santo, ouve a minha oração.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/denise-cardoso/de-madrugada/',
      ),
      Hino(
        codigo: 4,
        titulo: 'CENTO E VINTE HOMENS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cento e vinte homens no cenáculo oravam\nDe joelhos buscando poder,\nDe repente, quando menos esperavam,\nDeus mandou fogo que fez estremecer.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ó Deus, este povo que a ti clama\nEsperando fogo do altar,\nPara que esta igreja tenha nova vida,\nVem, ó Deus, o teu poder manifestar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na rua quem passava exclamava!\n"Este povo embriagado e infiel".\nPedro disse não é o que estais pensando,\npois se cumpre a profecia de Joel.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na cidade muitos foram confundidos\nPorque não souberam compreender\nPovos de muitas nações ali reunidos\nNão sabiam que de Deus era o poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmão, se ainda não és batizado,\nPermaneças em Jerusalém\nDe joelhos e continuo no cenáculo\nQue esse fogo pode te queimar também.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/corinhos-evangelicos/poder-do-alto/',
      ),
      Hino(
        codigo: 5,
        titulo: 'DE JOELHO É MELHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Certa vez um pastor, num caminho passou\nMuito triste a pensar.\nSua igreja era fria, sua alma vazia,\nNão tinha o que dar!\nEncontrou um guri trabalhando a sorrir,\nAjoelhado no pó;\nBanco lhe ofereceu e o guri lhe respondeu:\n“De joelho é melhor”.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'De joelho é melhor,\nDe joelho é melhor,\nNa alegria ou na dor,\nSempre orando ao Senhor\nDe joelho é melhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Esta voz lhe falou e bem alto tocou\nE o pastor refletiu;\nQuando o dia passou e a noite chegou\nFoi deitar não dormiu\nProcurou esquecer para adormecer\nFoi sempre pior\nParecia, até, ver o guri lhe dizer:\n“De joelho é melhor”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Foi assim que pensou e o Senhor lhe falou:\nTambém deves orar!\nA orar começou e Deus lhe abençoou,\nPode conciliar.\nSua igreja que, estava sem luz, não brilhava,\nTornou-se um farol,\nSempre alegre viveu depois que aprendeu:\n“De joelho é melhor”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Esta história eu li, para mim aprendi,\nTambém devo orar.\nSe você meu irmão, está em tribulação\nSem poder suportar,\nPeça a Deus em oração que os males se vão\nEspalhando ao redor,\nHumilhando aos seus pés, vences lutas cruéis,\n“De joelho é melhor”.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/de-joelhos-e-melhor/',
      ),
      Hino(
        codigo: 6,
        titulo: 'DERRAMA TEU ESPÍRITO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Derrama sobre nós o Teu Espírito,\nComo fizeste em Jerusalém;\nÀ Tua grei, ó manda o mesmo fogo,\nIndispensável para nós também!\nÀ tua grei, ó manda o mesmo fogo,\nIndispensável para nós também!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Derrama sobe nós o Teu Espírito,\nComo em casa do centurião,\nE dá-nos o poder da Tua Palavra\nFazendo a luz brilhar na escuridão.\nE dá-nos o poder da Tua Palavra\nFazendo a luz brilhar na escuridão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Derrama sobre nós o Teu Espírito\nE dá-nos, hoje, muitas conversões;\nÓ deixa-nos sentir poder celeste,\nE vivifica os nossos corações;\nÓ deixa-nos sentir poder celeste\nE vivifica os nossos corações.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Derrama sobre nós o Teu Espírito\nE aos que sofrem dá Tua protecão;\nA orar ficamos em amor unidos,\nPara obter a prometida unção,\nA orar ficamos em amor unidos,\nPara obter a prometida unção.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desperta, Jesus Cristo, os que dormem\nO mui profundo sono do “Jardim”;\nComo operaste nos antigos tempos,\nCom o teu poder nos guia até o fim.\nComo operaste nos antigos tempos,\nCom o teu poder nos guia até o fim',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/derrama-teu-espirito/gtzztp.html',
      ),
      Hino(
        codigo: 7,
        titulo: 'O DESCANSO EM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tens descanso encontrado em Jesus Cristo?\nPermaneces pela graça que ele deu?\nTens tu paz com teu Salvador bendito?\nPlenitude do Espírito de Deus?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tens descanso encontrado em Jesus Cristo?\nPermaneces pela graça que ele deu?\nPlena paz, consolação, acharás na oração:\nDeus aí vitória aos santos concedeu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Estarás bem seguro e corajoso\nQuando a tentação chegar-se para ti?\nTens a graça pra ser vitorioso\nNas terríveis provações da vida aqui.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Só em Cristo encontrarás descanso,\nQue ninguém aqui, jamais irá tirar;\nCom Jesus tu hás de aprender ser manso,\nE Sua glória em ti o mundo há de mirar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-descanso-em-jesus/',
      ),
      Hino(
        codigo: 8,
        titulo: 'EM FERVENTE ORAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em fervente oração, vem o teu coração,\nNa presença de Deus derramar,\nMas não podes fruir, que estás a pedir,\nSem que tudo abandones no Altar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quando tudo perante o Senhor estiver\nE todo o teu ser Ele controlar,\nSó então hás de ver, que o Senhor tem poder;\nQuando tudo deixares no Altar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Maravilhas de amor, te fará o Senhor,\nAtendendo a oração que aceitar,\nSeu imenso poder, te vira socorrer,\nQuando tudo deixares no Altar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se orares então, sem que teu coração,\nGoze a Paz, que o Senhor pode dar.\nE que Deus não sentiu, que tua alma se abriu,\nTudo, tudo, deixando no Altar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/em-fervente-oracao/',
      ),
      Hino(
        codigo: 9,
        titulo: 'HORA BENDITA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bendita hora de oração,\nPois traz-nos paz ao coração,\nE sobrepuja toda dor,\nTrazendo auxílio do Senhor.\nEm tempos de perturbação,\nNa dor maior, na tentação,',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto: 'Procurarei com mais fervor\nA comunhão com o Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bendita hora de oração,\nProduto só da devoção,\nQue eleva ao céu o seu odor\nEm doce cheiro a meu Senhor.\nE finda a hora da aflição,\nOs dias maus, a tentação,',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto: 'Então darei melhor louvor\nA meu Jesus, a meu Senhor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bendita hora de oração,\nPois liga-nos em comunhão,\nE traz-nos fé e mais amor;\nEnchendo o mundo de dulçor.\nDesejo a vida aqui findar\nCom fé, amor, constante orar;',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto: 'Depois da morte, do pavor,\nEntão será, sim, só louvor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/148-hora-bendita/',
      ),
      Hino(
        codigo: 10,
        titulo: 'IMPLORAMOS TEU PODER',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Imploramos, nosso Salvador,\nTeu poder, teu poder, teu poder,\nDivinal, poder renovador,\nTeu poder, teu poder, teu poder.\nBendita promessa paternal!\nVem encher-nos de real valor,\nDo pleno poder celestial,\nTeu poder, teu poder, teu poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com o óleo, sim, vem nos ungir,\nTeu poder, teu poder, teu poder,\nPai celeste, faze-nos fruir\nTeu poder, teu poder, teu poder.\nTu já prometeste derramar\nTuas bençãos e nos revestir,\nP\'ra tua palavra proclamar ,\nCom poder, com poder, com poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com o fogo vem nos inflamar,\nTeu poder, teu poder, teu poder\nE de toda mancha nos limpar,\nTeu poder, teu poder, teu poder\nAquece os frios, ó Senhor;\nFaze os que dormem despertar.\nNós te suplicamos com fervor,\nTeu poder, teu poder, teu poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como a brisa, queiras assoprar\nTeu poder, teu poder, teu poder\nDeus bendito, vem nos outorgar\nTeu poder, teu poder, teu poder\nPerene e doce comunhão,\nQuero aqui contigo, ó Pai, gozar;\nDepressa nos enche o coração\nCom poder, com poder, com poder.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/155-imploramos-teu-poder/',
      ),
      Hino(
        codigo: 11,
        titulo: 'LEVANTA CEDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Levanta cedo, prá buscar poder,\nAo romper do dia, todo mal vencer;\nJesus dá vitória a quem obedecer ,\nDerrota na vida, jamais há de ter.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sem este poder,\nNão, não vai,                              (Bis)\nOs dias são de trevas,\nSem poder o crente cai.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O poder das trevas, vem de todo lado,\nProcurando os crentes que estão descuidados;\nO Espírito Santo tem nos despertado;\nTodos que obedecem não são derrotados',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando vem as lutas, vamos pelejar,\nA vitória é certa, em Deus confiar;\nEntra na batalha que tu vais vencer,\nJesus dá vitória a quem obedecer',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 12,
        titulo: 'NO JARDIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No jardim, Jesus Cristo clamava,\nQuando os ímpios O foram prender;\nE falando co\'o Pai suplicava,\nPelo cálice que ia beber',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Com Jesus a minh\'alma deseja estar\nNo jardim, em constante oração;\nQuando a noite chegar, e o mal me cercar\nQuero estar em constante oração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Qual orvalho que dá vida às flores,\nAssim é para o crente a oração;\nMeus cuidados, tristezas e dores,\nCristo as sabe por minha oração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus teve completa vitória,\nPorque sempre viveu em oração,\nMuitos santos chegaram à glória,\nSob o manto da doce oração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Renovados em forças seremos,\nNós teremos uma nova unção;\nE com Deus, no jardim falaremos,\nSe vivermos sempre em oração',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/no-jardim/',
      ),
      Hino(
        codigo: 13,
        titulo: 'SENHOR, MANDA TEU PODER',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os fiéis oravam unidos\nNum Cenáculo ao Senhor,\nQuando foi do céu descido\nO real Consolador',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Senhor, manda já o Teu poder\nSenhor, manda já o Teu poder\nSenhor, manda já o Teu poder\nE batiza cada um!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Qual um vento veemente,\nO poder a casa encheu;\nLínguas vieram sobre os crentes,\nMas de fogo, lá do Céu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Noutras línguas, sim, falaram,\nComo Cristo concedeu;\nDo Espírito transbordaram,\nExaltando o Rei do ceu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O poder foi prometido\nPara os servos do Senhor;\nÉ pra todos concedido,\nSe o pedirem com fervor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/senhor-manda-teu-poder/gttmpw.html',
      ),
      Hino(
        codigo: 14,
        titulo: 'SONDA-ME Ó DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sonda-me, ó Deus, pois vês meu coração;\nProva-me, ó Pai, te peço em oração;\nDe todo mal liberta-me Senhor,\nTambém de transgressão que oculta for.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem me limpar dos vis pecados meus,\nConforme prometeste, ó meu Deus;\nFaze-me arder e consumir de amor,\nPois quero te magnificar Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Todo o meu ser, que já não chamo meu,\nQuero gastá-lo no serviço teu;\nMinhas paixões tu podes dominar,\nEu me submeto, em mim vem sempre estar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá do alto céu o avivamento vem,\nA começar em mim e indo além;\nO teu poder, tuas bênções, teu fervor,\nConcede aos filhos teus, ó Pai de amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/sonda-me-o-deus/',
      ),
      Hino(
        codigo: 15,
        titulo: 'TEU ESPÍRITO VEM DERRAMAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Senhor, nós esperamos\nQue escutes a oração;\nNós, Teus servos, já clamamos,\nCom humilde coração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Teu Espírito, vem derrama,\nSobre cada coração!\nE no crente, que a Ti clama,\nVem, confirma a petição',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deixa o fogo do Espírito\nSim, nos corações arder,\nP\'ra que tudo que é finito,\nJamais possa se reter .',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Senhor, me purifica,\nTira o mal que está em mim,\nA minh\'alma santifica,\nE me guarda até o fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dá-nos mais da Tua graça,\nE enche-nos do Teu poder,\nDo teu templo, ó Deus, se faça\nA Tua voz se perceber.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dá-nos dons do Teu Espírito;\nFaz milagres, ó Senhor,\nP\'ra que tudo, que tens dito,\nCumpra-se, meu Redentor.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Dou-Te graças, Rei da Glória,\nPois ouviste a petição;\nBelos hinos de vitória,\nMais tu deste ao coração.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/teu-espirito-vem-derramar/',
      ),
      Hino(
        codigo: 16,
        titulo: 'VAI ORANDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De pesar estás cercado, \nÉs provado pela dor? \nDe sofrer estás cansado, \nE também do teu labor?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vai orando, vai orando, \nAo soprar do furacão, \nO Senhor está velando, \nDar-te-á consolação',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nas doenças, incertezas, \nQue tu\'alma passará, \nSó Jesus dará firmeza, \nE também te curará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao Senhor a voz eleva, \nOra a Deus com mui fervor, \nPois as faltas te releva \nE mitiga a tua dor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tarda Deus em consolar-te? \nVai orando com poder; \nPresta, ajuda pode dar-te, \nTeu pedido responder.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vai-orando/gtkjhg.html',
      ),
      Hino(
        codigo: 17,
        titulo: 'VOU COM ELE ORAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a noite desce, vou além orar \nCom meu companheiro no santo lugar \nCristo e meu amigo chefe do meu lar \nQuando a noite desce vou com Ele orar',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vou com Ele orar, vou com Ele orar \nQuando a noite desce vou com Ele orar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Conto-lhe as tristezas do meu coração \nGozo, então, com Ele doce comunhão \nSinto a minha vida em paz se tornar \nQuando a noite desce vou com Ele orar ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero nesta vida santidade enfim \nJá não mais eu vivo Cristo vive em mim \nNeste avivamento, vamos caminhar \nQuando a noite desce vou com Ele orar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No labor da noite vamos construir \nCabanas pra os santos no doce porvir \nHó! Quanto alegria ver transfigurar \nQuando a noite desce vou com Ele orar',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 18,
        titulo: 'VIEMOS ORAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Viemos aqui a orar \nTambém em repouso sentir \nDe Deus a presença sem par \nE calmo sua voz ouvir.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim! Sim! Sim! Sim! \nDeus aqui falará! \nSim! Sim! Sim! Sim! \nMinh\'alma Ele ouvirá',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lembremos das pedras dos rios \nQue impedem as águas passar \nTambém o pecado impede \nDe Deus a vitória alcançar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Contemos a Ele as tristezas \nQue afligem o coração \nQue nada destrua a beleza \nDa nossa real comunhão.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 19,
        titulo: 'VEM, VISITA TUA IGREJA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem! Visita! Tua igreja \nÓ bendito Salvador! \nSem tua graça ela murcha \nFicará, e sem vigor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vivifica, vivifica,                ( Bis ) \nNossas almas, ó Senhor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/vem-visita-tua-igreja/',
      ),
      Hino(
        codigo: 20,
        titulo: 'VIVIFICA-NOS, SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus presente está conosco, \nPronto todos a salvar; \nSobre as almas sequiosas, \nQuer Sua bênção derramar',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Manda, ó manda as ricas chuvas \nDa Tua bênção, Salvador! \nImploramos! Esperamos! \nVivifica-nos, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis a Ti, Senhor, erguemos \nNossos pobres corações; \nNa Tua grande e rica graça, \nOuve as nossas petições!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Torna a nossa fé mais viva, \nMais ardente o nosso amor; \nEnche-nos de santo zelo, \nDe coragem e fervor.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 21,
        titulo: 'EU CREIO NUM SER',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu creio num Ser, que faz estremecer \nO mundo e o céu, \nÉ Santo Subterno de amor sempiterno \nQue chama-se Deus \nEu creio num Ser, que teve o poder, \nDos anjos criar, \nE numa expansão que Sua mansão, \nOs fez habitar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu creio num Ser, Senhor do poder, \nDo tempo e progresso, \nO espaço formou e nele fundou \nO grande Universo; \nEu creio num Ser, que faz florescer, \nOs campos e os prados, \nAcalma, as procelas, dá luz as estrelas, \nE paz aos cansados.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu creio num Ser, que faz renascer \nAs ervas do solo, \nO sol faz luzir, e a chuva cair \nPra sabios e tolos; \nEu creio num Ser, que é no dizer, \nNo agir e no pensar \nÉ justo e bondoso, é Rei amoroso, \nO glória sem par.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu creio num Ser, que faz perecer \nO império do mal, \nDestrói o pecado, humilha o exaltado, \nCondena o carnal; \nEu creio num Ser, que deu a morrer \nSeu filho Jesus, \nO qual padeceu, Seu sangue verteu, \nPor nos lá na cruz.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 22,
        titulo: 'AO ABRIR O CULTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nós abrimos este culto \nEm Teu Nome, ó Jesus Cristo! \nAo pequeno e ao adulto. \nLuz divina vem dar por isto; \nGozaremos em Tua face, \nÓ Cordeiro ressuscitado! \nCom doçura, sim, nos enlaces, \nPara ouvir o que nos for dado.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó nos manda Tua Palavra \nPelo Teu Espírito Santo, \nQue no peito um fogo lavra, \nQue enxuga também o pranto; \nNosso Pai, nós Te suplicamos \nNova vida p\'ra tua igreja; \nÓ não tardes, pois desejamos \nQue pureza em nós tu vejas.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Abençoa, ó Deus santo, \nOs teus servos em todo o mundo; \nAbençoa o nosso canto \nE dá vida aos moribundos; \nAbençoa aos cordeirinhos, \nA família dos Teus amados, \nComo ave, que no seu ninho, \nTem seus filhos bem abrigados.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ao-abrir-culto-243/',
      ),
      Hino(
        codigo: 23,
        titulo: 'COMUNHÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Preciosas são as horas \nNa presença de Jesus! \nComunhão deliciosa \nDa minh\'alma com a luz! \nOs cuidados deste mundo \nNunca podem me abalar, \nPois é Ele o meu abrigo, \nQuando o tentador chegar           (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao sentir-me rodeado \nDe cuidados terreais, \nIrritado, abatido, \nOu em dúvidas fatais, \nA Jesus eu me dirijo \nNesses tempos de aflição, \nAs palavras que Ele fala \nTrazem-me consolação                (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se confesso meus pecados. \nToda a minha imperfeição, \nEle escuta com paciência \nEsta triste confissão; \nCom ternura repreende; \nMeu pecado e todo mal. \nEle é sempre o meu amigo \nO melhor e mais leal                     (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se quereis saber quão doce \nÉ a secreta comunhão, \nPodereis mui bem próva-la, \nE tereis compensação \nProcurai estar sozinhos \nEm conversa com Jesus \nProvareis na vossa vida \nO Espírito da Cruz!                        (Bis)',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/vencedores-por-cristo/preciosas-sao-as-horas/',
      ),
      Hino(
        codigo: 24,
        titulo: 'INVOCAÇÃO E LOUVOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem Tu, ó Rei dos reis, \nGuiar os teus fiéis p\'ra te louvar. \nGrande e glorioso Ser, Pai de todo o poder, \nVem sobre nós reger, oh! Deus sem par!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem Tu, Verbo de Deus, \nFazer chegar aos céus nossa oração, \nVem, sim, abençoar teu povo e prosperar \nMensagem que falar da salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Tu, Consolador, \nInspira e dá fervor às orações; \nEspírito de paz, afasta Satanás, \nE plena graça traz aos corações.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao grande e trino Deus \nLouvem os anjos Seus e nós também, \nA Deus nosso Senhor: Pai, Filho e Condutor \nLouvemos com fervor, p\'ra sempre. Amém.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vem-tu--rei-dos-reis/',
      ),
      Hino(
        codigo: 25,
        titulo: 'PASTOR DIVINO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ouve-nos, Pastor divino, \nNós, que neste bom lugar, \nTeu rebanho congregado, \nDesejamos-Te adorar. \nCristo amado, Cristo amado, \nVem teu povo abençoar.              (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao perdido no pecado \nSeu perigo faze-o ver; \nChama os pobres enganados, \nFaze-os tua voz ouvir; \nAos enfermos, aos enfermos, \nMestre, digna-Te acudir.              (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Traze o pobre desgarrado \nAo aprisco teu, Senhor; \nToma o tenro cordeirinho \nNo regaço teu, Pastor; \nDá-lhe os pastos, dá-lhe os pastos \nDe celeste e doce amor.             (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Jesus, escuta o rôgo, \nNossa humilde petição; \nVem encher o teu rebanho \nDe sincera devoção; \nCantaremos, cantaremos \nTua afável proteção                    (Bis)',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/pastor-divino/',
      ),
      Hino(
        codigo: 26,
        titulo: 'VEM, Ó TODO PODEROSO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Ó todo poderoso, \nAdorável Criador, \nPai eterno e caridoso, \nVem, revela o Teu amor. \nAnte o trono de clemência \nNos prostramos e, a uma voz, \nSuplicamos a Tua assistência, \nDeus e Pai de todos nós. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, ó Salvador benígno, \nDeus da nossa salvação; \nVem, confirma o Teu ensino \nVive em cada coração. \nÉs o Cristo, dom glorioso, \nDom de sempiterno amor! \nOuve-nos, Jesus bondoso, \nVem, bendize-nos Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Espírito de graça, \nNosso culto abençoar; \nDeus Consolador, enlaça \nTeus fiéis neste lugar, \nEsclarece as nossas mentes, \nInfalível preceptor! \nE seremos fortes crentes, \nDominados pelo amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/066-vem--todo-poderoso/',
      ),
      Hino(
        codigo: 27,
        titulo: 'SUAS PROMESSAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus dá-nos promessas, Deus cumpre o que diz; \nJamais foi a fé iludida. \nSe sentes tristezas e provações vis \nDeus nunca as promessas olvida.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Suas santas promessas bem firmes estão \nQual rocha no mar desta vida \nE os que têm fé, em breve verão \nDeus nunca as promessas olvida.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem buscar achará, quem pedir vai obter \nA bênção por Deus prometida; \nJamais vai em vão a Deus recorrer \nDeus nunca as promessas olvida.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se sofres e gemes na força da dor , \nDeus dá à tua alma, ferida, \nConsolo sublime com voz de amor. \nDeus nunca as promessas olvida.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 28,
        titulo: 'DEUS NOS GUARDE NO SEU AMOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus nos guarde bem no Seu amor; \nOnde quer que nos achemos, \nO Seu Nome louvaremos; \nDeus nos guarde bem no Seu amor!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ao voltar Jesus vamos nós estar \nLivres de qualquer separação; \nU\'a coroa, então vamos, sim, formar, \nLá no céu, na eternal mansão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus nos guarde em santificação \nNas agruras da jornada, \nQue é mui breve terminada! \nDeus nos guarde em santificação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus nos guarde e nos conceda paz, \nDe que tanto carecemos; \nÓ, enquanto aqui vivemos, \nDeus nos guarde e nos conceda paz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/deus-nos-guarde-no-seu-amor/',
      ),
      Hino(
        codigo: 29,
        titulo: 'DIVINO COMPANHEIRO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Divino companheiro no caminho \nTua presença sinto logo ao transitar \nTu dissipaste toda sombra \nJá tenho luz, a luz bendita do amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Fica Senhor já se faz tarde \nTens meu coração para pousar \nFaz em mim morada permanente \nFica Senhor, fica Senhor meu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A sombra da noite se aproxima \nE nela o tentador vai chegar \nNão! não me deixes só no caminho \nAjuda-me! Ajuda-me até chegar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em ti depositei minha esperança \nAté chegar ao fim do meu jornadear \nCom tua presença permanente \nIrei Senhor! Irei Senhor no céu morar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/corinhos-evangelicos/divino-companheiro/',
      ),
      Hino(
        codigo: 30,
        titulo: 'DESPEDE-NOS, Ó BOM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Despede-nos, ó bom Jesus, \nNo fim do Teu serviço aqui \nNo santo trilho nos conduz, \nPra que sirvamos só a Ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Despede-nos, despede-nos, \nDespede-nos em Teu amor. \nPermite que nós outra vez \nNos ajuntemos, ó Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cuida de nós, ó bom Jesus, \nE não nos largue a Tua mão, \nO teu amor já nos induz \nA Te amar de coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pai nosso, Tu, que estás nos Céus, \nAbençoar-nos aqui vem, \nÓ Tu, Espírito de Deus, \nRegenerar-nos vem também.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 31,
        titulo: 'AO RAIAR DO ANO NOVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É meia noite, o ano já fenece, \nNós elevamos os olhos aos Céus, \nTodos orando para que comece \nO ano novo da graça de Deus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'As nossas vozes juntas levantemos, \nCom alegria e suave som; \nEm gratidão a Cristo, jubilemos, \nPelo raiar de mais um ano bom.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Senhor, pedimos ardentemente, \nOuve, por Teu infinito amor; \nSalva da nossa pátria toda gente, . \nP\'ra Tua honra, e p\'ra Teu louvor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As nossas almas torna impolutas, \nNão nos deixando em fraqueza cair, \nNossa oração, Senhor, hoje escuta \nPara podermos aqui Te servir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Graças a Ti, por esse ano findo \nPois nos supriste com muito poder; \nGraças a Ti, por esse ano vindo, \nPois bençãos mil vamos nós receber.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ao-raiar-do-ano-novo/',
      ),
      Hino(
        codigo: 32,
        titulo: 'ANO NOVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Rompe a aurora, vai-se embora \nMais um ano de labor; \nNão temamos, prossigamos, \nA luta com mais ardor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'O ano findo nunca mais veremos; \nO ano novo hoje recebemos! \nVê, vê, o belo dom que Deus nos dá!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cada dia Cristo, o Guia, \nNos remove o coração; \nTemos gozo, bom repouso, \nConfiando em sua mão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do pecado resgatados, \nPertencemos a Jesus; \nNova vida, santa lida, \nTemos nós por sua cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hinos santos entoemos \nE louvemos ao Senhor! \nVem do arcano mais um ano \nque anuncia seu favor!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/ano-novo/',
      ),
      Hino(
        codigo: 33,
        titulo: 'PARA OS MONTES OLHAREI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para os montes olharei! \nDe onde vem a salvação? \nMeu socorro vem de Deus, \nO Senhor da Criação.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'O Senhor é quem te guarda, \nGuardará de todo mal. \nTua entrada e saída, \nDesde agora até o final.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Senhor é quem te guarda, \nSob a sua destra estás. \nNem de dia, nem de noite, \nMal algum sucederá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Senhor é quem te guarda, \nNão te deixará cair. \nComo a Israel guardava, \nNão dormiu e nem vai dormir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/para-os-montes-olharei/',
      ),
      Hino(
        codigo: 34,
        titulo: 'ALMAS GÊMEAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Almas gêmeas que se enlaçam \nPelos elos da afeição, \nTé que a morte ao fim os venha separar. \nLado a lado um do outro \nPela vida seguirão, \nPara unidos os encantos desfrutar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Chovam bênçãos sobre o venturoso par, \nQue se encontram lado a lado neste altar. \nDá-Ihe Deus a proteção e uma sólida união, \nAlicerces para seu ditoso lar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A brancura da grinalda \nA finura desde véu \nejam símbolos de um puro e casto amor \nSeja o lar aqui na terra, miniatura lá do céu \nHospedando sempre a Cristo Redentor,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pela fé sempre aquecidos \nCom amor no coração, \nOmbro a ombro, lado a lado irão lutar, \nQuer nos dias bonançosos \nNa borrasca ou na aflição, \nHão de vidas sempre juntos partilhar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/almas-gemeas/',
      ),
      Hino(
        codigo: 35,
        titulo: 'BENIGNO SALVADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Benigno Salvador! Com Tua aprovação, \nConsagra em doce amor esta feliz união, \nE sobre os noivos faz descer \nA graça que lhes é mister.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fá-los em paz andar unidos no Senhor, \nE a vida aqui passar em terno e santo amor \nLigados no amor de Deus, \nCaminhem juntos para os céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó digna-Te reger sua casa como Rei; \nSeus corações manter dóceis, à Tua lei; \nLivra-os de toda tentação, \nConsola-os na tribulação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se o Salvador cumprir a nossa petição, \nPodemos descobrir nesta bendita união \nA sombra do celeste amor \nDos salvos e seu Salvador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/benigno-salvador/completa.html',
      ),
      Hino(
        codigo: 36,
        titulo: 'COM TUA MÃO SEGURA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com Tua mão, segura bem a minha \nPois eu tão fraco sou, ó Salvador! \nQue não me atrevo a dar nem um só passo \nSem Teu amparo, meu Jesus Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com Tua mão, segura bem a minha \nE mais e mais unido a Ti, Jesus \nO traze-me, que nunca me desvie \nDe Ti, Senhor, à minha Vida e Luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com Tua mão, segura bem a minha, \nE, pelo mundo, alegre seguirei; \nMesmo onde as sombras caem mais escuras \nTeu rosto vendo, nada temerei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E, se chegar à beira desse rio, \nQue Tu por mim quiseste atravessar, \nCom Tua mão segura bem a minha, \nE sobre a morte eu hei de triunfar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando voltares esses céus rompendo, \nSegura bem a minha mão, Senhor \nE, meu Jesus, ó leva-me contigo \nPara onde eu goze Teu eterno amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/com-tua-mao-segura/gwtwgh.html',
      ),
      Hino(
        codigo: 37,
        titulo: 'DIA FESTIVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que alegria neste dia \nNós estamos a gozar! \nNeste ensejo bom desejo \nTemos só a Deus louvar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh, cantemos, pois, com alegria \nNeste grande e mui festivo dia! \nVê! Vê o que nos fez o Rei dos reis!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que alegria neste dia \nEnche-nos o coração! \nInimigos e perigos \nJá venceu o Capitão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que alegria neste dia \nTêm os crentes em Jesus; \nReunidos os remidos, \nFazem tudo em sua luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus glorioso, Deus bondoso, \nAbençoa-nos aqui; \nQue esta igreja sempre seja \nConsagrada só a ti!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/411-dia-festivo/',
      ),
      Hino(
        codigo: 38,
        titulo: 'DEUS VOS GUARDE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus vos guarde pelo seu poder,\nSempre esteja ao vosso lado,\nVos dispense o seu cuidado,\nDeus vos guarde pelo seu poder.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Pelo seu poder, e o seu amor,\n“Té nos encontrarmos com Jesus".\nPelo seu poder e o seu amor,\nOh! que Deus vos guarde em sua luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus vos guarde bem no seu amor,\nConsolados e contentes,\nAchegados para os crentes;\nDeus vos guarde bem no seu amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus vos guarde do poder do mal,\nDa ruína, do pecado,\nDos motins de qualquer lado;\nDeus vos guarde do poder do mal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus vos guarde para o seu louvor,\nPara o seu presente gozo,\nSeu serviço glorioso;\nDeus vos guarde para o seu louvor.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 39,
        titulo: 'QUAL O ADORNO DESTA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Qual o adorno desta vida? \nÉ o amor, é o amor. \nAlegria é concedida pelo amor, pelo amor. \nÉ benigno, é paciente,                                        (Bis)\nNão se torna maldizente \nEste meigo amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com suspeita não se alcança \nDoce amor, doce amor \nOnde houver desconfiança, ai do amor, ai do amor! \nPois mostremos tolerância; \nMuitas vezes a arrogância                                 (Bis)\nMurcha e mata o amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ainda quando for custoso, \nNutre amor, nutre amor; \nAo irado e furioso mostra amor, mostra amor. \nNão te dês por insultado,                                   (Bis)\nMas responde com agrado\nVence pelo amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não te irrites, mas tolera \nCom amor, com amor; \nTudo sofre, tudo espera pelo amor, pelo amor. \nSentimentos orgulhosos \nNão convêm aos criminosos                            (Bis)\nSalvos pelo amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois, irmão, ao teu vizinho \nMostra amor, mostra amor. \nO valor não é mesquinho deste amor, deste amor. \nO supremo Deus nos ama. \nCristo para os céus nos chama,                       (Bis)\nOnde reina o amor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/hino-380-amor/',
      ),
      Hino(
        codigo: 40,
        titulo: 'SE AS ÁGUAS DO MAR DA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se as águas do mar da vida, quiserem te afogar, \nSegura na mão de Deus e vai. \nSe as tristezas desta vida quiserem te sufocar, \nSegura na mão de Deus e vai.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Segura na mão de Deus \nPois Ela, Ela te sustentará. \nNão temas, segue adiante                   (Bis)\nE não olhes para trás \nSegura na mão de Deus e vai.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se a jornada é pesada e te cansas na caminhada, \nSegura na mão de Deus e vai. \nOrando, jejuando, confessando e confiando, \nSegura na mão de Deus e vai.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Espírito do Senhor sempre te revestirá. \nSegura na mão de Deus e vai. \nJesus Cristo prometeu e jamais te deixará, \nSegura na mão de Deus e vai.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/se-as-aguas-do-mar-da-vida/',
      ),
      Hino(
        codigo: 41,
        titulo: 'TUDO É BELO EM DERREDOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo é belo em derredor, com amor no lar; \nHá beleza em cada flor. \nCom amor no lar, \nPaz e gozo conceder, amarguras desfazer, \nE saúde promover, vem o amor no lar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Com amor, com amor, \nNão há dor, não há pesar \nCom amor no lar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na choupana há prazer, com amor no lar; \nÓdio e mal não pode haver, com amor no lar; \nCada rosa no jardim, canta hinos para mim, \nDando à vida alegre fim, com amor no lar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Todo o céu parece rir, com amor no lar. \nTodo o mundo refletir este amor no lar; \nDo regato o murmurar e das aves o cantar, \nTudo faz-nos jubilar, com amor no lar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu Jesus, oh! Faze-me teu, dando amor no lar; \nFaz-me renunciar ao eu, faz-me mais amar; \nConfiando eu deporei toda a carga aos pés do Rei, \nSempre amando a sua lei, com amor no lar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/453--amor-no-lar/',
      ),
      Hino(
        codigo: 42,
        titulo: 'UNIÃO VITAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Duas vidas, Senhor, se unem num só ser, \nDuas almas e dois nobres corações; \nPelo amor e afeição mútua assim viver \nQuerem, juntos na paz ou nas aflições.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Abençoa, Senhor, esta santa união, \nDando graça e favor, faze-a prosperar \nNa alegria, na fé, na consagração: \nQue ambos sempre só queiram contigo andar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mais um lar que se faz cheio do vigor \nDo caráter cristão, base principal \nDuma vida feliz numa união de amor, \nQue abençoa e mantém a paz conjugal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Preparaste, Senhor, para o gozo e paz \nDo teu povo que habita esta terra aqui, \nEssa união tão feliz, que amplas bênçãos traz. \nGratos, pois, entoamos louvor a Ti!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 43,
        titulo: 'A FORMOSA JERUSALÉM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quão glorioso, cristão, é pensares \nNa cidade que não tem igual, \nOnde os muros são de puro jaspe, \nE as ruas de ouro e cristal; \nPensa como será glorioso \nVer-se a triunfal multidão, \nQue cantando, aguarda a chegada \nDos que vencem a tribulação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pensa como será glorioso \nVer o rio da vida e luz, \nCujas margens juncadas de lírios, \nSão a glória de nosso Jesus, \nHaverá lá perpétua aurora \nPois Deus mesmo a iluminará. \nE o Cordeiro, com Sua esposa, \nNoite e dia resplandecerá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pensa na celestial melodia \nQue a terra encherá, de Beulá; \nE das harpas a doce harmonia \nAo passar o Jordão se ouvirá, \nMesmo em dores que levem à morte, \nSê constante, não voltes atrás, \nTua herança, tua eterna sorte, \nÉ Jesus, o Fiel, o Veraz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se é glorioso pensar nas grandezas, \nNos prazeres que acodem aqui, \nQual será desfrutar as riquezas \nQue esperam os salvos, ali? \nOs encantos do mundo não podem \nOfuscar essa glória dalém; \nNão almejas viver, ó amigo, \nNessa formosa Jerusalém?',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-formosa-jerusalem-026/',
      ),
      Hino(
        codigo: 44,
        titulo: 'A MINHA CASA NÃO TEM A BELEZA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A minha casa não tem a beleza, \nQue muitas outras no mundo aqui, \nMas não importa a minha riqueza \nÉ sempre eterna com os anjos ali.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu tenho uma casa naquela cidade, \nResplandecente com celeste fulgor, \nDa minha pátria eu tenho saudade, \nHei de estar com Jesus meu Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aqui na terra as lutas não cessam, \nAs tentações me atacam sem fim, \nPorém em breve de tudo me esqueço, \nGozando delícias preparadas pra mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não me julgues pobre nem desamparado, \nPeregrinando com Cristo eu vou, \nNão estou triste, nem desanimado, \nParticipante de um reino eu sou.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-aleluia/a-minha-casa-nao-tem-a-beleza-hino-287/',
      ),
      Hino(
        codigo: 45,
        titulo: 'A BELA CIDADE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho lido da bela cidade \nConstruída por Cristo nos céus; \nÉ murada de jaspe luzente \nE juncada com áureos troféus, \nE, no meio da praça, eis o rio \nDo vigor e da vida eternal; \nMas metade da glória celeste \nJamais se contou ao mortal.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jamais se contou ao mortal; \nJamais se contou ao mortal; \nMetade da glória celeste                     (Bis)\nJamais se contou ao mortal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho lido das belas moradas \nQue Jesus foi no céu preparar, \nOnde os crentes fiéis, para sempre, \nMui felizes irão habitar. \nNem tristeza, nem dor, nem gemidos \nEntrarão na mansão paternal; \nMas metade do gozo celeste \nJamais se contou ao mortal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho lido das vestes brilhantes, \nDas coroas que os santos terão \nQuando o Pai os chamar e disser-lhes: \n“Recebei o eternal galardão.” \nTenho lido que os santos na glória \nPisarão ruas de ouro e cristal; \nMas metade da glória celeste \nJamais se contou ao mortal',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-bela-cidade/',
      ),
      Hino(
        codigo: 46,
        titulo: 'AO PASSAR O JORDÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando o Jordão passarmos unidos, \nE entrarmos no Céu, veremos lá, \nComo areia da praia os remidos, \nOh! Que gloriosa vista será!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tantos como a areia da praia! \nTantos como a areia do mar! \nQue gozo sentirá \nTodo o salvo pois verá, \nSim, tantos como a areia da praia!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando virmos os salvos do mundo, \nQue a morte jamais alcançará, \nSe saudarem com gozo profundo, \nOh! Que gloriosa vista será!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá na margem do Rio da Vida, \nOnde  paz e justiça haverá, \nNós veremos a terra prometida; \nOh! Que gloriosa vista será!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando Cristo Jesus contemplarmos, \nCoroado no Céu como está, \nE prostrado aos Seus pés adorarmos, \nOh! Que gloriosa vista será!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ao-passar-jordao/',
      ),
      Hino(
        codigo: 47,
        titulo: 'A CIDADE CELESTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Sião celeste, repouso dos santos, \nO teu arquiteto se chama o SENHOR; \nEm Ti entraremos, com gozo e canto, \nCom os que adoram o bom Salvador, \nEm bela planície estás situada, \nE que majestosa rainha és tu! \nDe pedras preciosas estás adornada; \nDemonstras a glória de Cristo Jesus. \nDe Cristo Jesus, de Cristo Jesus. \nDemonstras a glória de Cristo Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Teus belos caminhos tratados com zelo, \nE as tuas torres, que vistas farão! \nDe todos os palácios, grandioso é o modelo; \nEm ti nós teremos a consolação; \nAs portas do muro são todas formosas; \nA praça é calçada de ouro que luz; \nEm ti essas coisas são mui gloriosas, \nE és toda cheia da paz de Jesus! \nDa paz de Jesus, da paz de Jesus. \nE és toda cheia da paz de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jamais haverá em ti noite alguma, \nTeu grande luzeiro perpétuo será; \nSem a luz do sol, nem d\'estrelas ou lua, \nA glória de Cristo te alumiará. \nE neste esplendor, de um sol verdadeiro, \nOs santos e anjos do céu entrarão, \nE virá na frente Jesus, o Cordeiro; \nCom Ele p\'ra sempre ali reinarão. \nAli reinarão, ali reinarão. \nCom Ele p\'ra sempre ali reinarão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que grande festa nos é concedida, \nCom a mesa posta, espera o Senhor, \nA todos inscritos no Livro da Vida, \nE que já da morte não tem mais temor; \nDe todos os que foram por Cristo comprados, \nO lindo cortejo composto será; \nE Deus, que há dado o Seu filho amado, \nCom Cristo na glória, os consolará, \nOs consolará, os consolará, \nCom Cristo na glória, os consolará.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-cidade-celeste/completa.html',
      ),
      Hino(
        codigo: 48,
        titulo: 'CÉU DE LUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O céu é um lugar onde irei morar, \nLugar de Santa paz e vida eternal. \nO céu é um lugar, lugar bom e ditoso, \nO céu é um lugar, lugar maravilhoso!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Céu, céu, morada de Jesus, \nCéu, céu, lugar de santa luz! \nCéu, céu, lugar bom e ditoso, \nO céu é um lugar, lugar maravilhoso!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelas suas portas, não podem penetrar, \nOs que não acharem seu nome escrito lá, \nLá no céu só entra os salvos em pleno gozo, \nO céu é um lugar, lugar maravilhoso!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelas suas praças, não passeia o malfeitor, \nPelas suas ruas, enterros não passarão. \nLá tudo é vida, prazer e santo gozo, \nO céu é um lugar, lugar maravilhoso!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 49,
        titulo: 'EU CONFIO FIRMEMENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu confio firmemente, \nQue no Céu vou descansar \nCom Jesus alegremente, aleluia! \nQue prazer celeste sente \nA minh\'alma em pensar, \nNa glória que no Céu eu vou gozar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Que eterna glória vou no Céu gozar! \nCom Jesus, que do pecado me salvou; \nSanta paz e alegria lá no Céu vou desfrutar, \nEterna glória Cristo me comprou!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No Céu vou ver o Cordeiro, \nQue por mim quis expirar, \nPendurado no madeiro, aleluia! \nQue me fez também herdeiro \nDo que nunca vai murchar, \nDa glória que no Céu eu vou gozar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De Jesus, o rosto santo, \nNo Céu hei de contemplar, \nOnde não há dor ou pranto, aleluia! \nMas sim um sublime canto \nQue p\'ra sempre vai soar \nNa glória, que no Céu eu vou gozar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando for ao Céu chegado \nE a glória alcançar \nPor ter Cristo ao meu lado, aleluia! \nNo Seu trono assentado, \nA Jesus vou adorar; \nEterna glória vou no Céu gozar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/eu-confio-firmemente/',
      ),
      Hino(
        codigo: 50,
        titulo: 'FINDA A LIDA TERREAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Finda a lida terreal \nQuando já do rio além, \nNessa vida tão gloriosa me encontrar, \nSei que lá meu Redentor \nSorridente eu hei de ver \nEntre todos o primeiro a me chamar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Hei de vê-lo, hei de vê-lo! \nRedimido ao seu lado hei de estar \nHei de vê-lo, hei de vê-lo \nDistinguindo dos cravos os sinais.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! da alma meu enlevo \nÉ seu rosto contemplar \nNessa aurora do dia eternal \nComo então meu coração \nÓ não há de ali louvar \nPela graça e favor celestial!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nessa Pátria resplendente, \nHei de amigos encontrar, \nSim amigos mais prezados hei de ter \nMas primeiro que tudo \nQuando eu ali chegar \nMeu Jesus é quem eu mais anseio ver.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelas portas da cidade \nCom as vestes a alvejar, \nOnde a noite e o pranto não estarão; \nEntre canto Angelical \nHá meus passos de guiar; \nPerto, sim mui perto eu hei de vê-lo então.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 51,
        titulo: 'GLÓRIA PRA MIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando meu tempo de lutas passar, \nQuando meu Deus para si me chamar, \nGrato, perante Jesus hei de estar; \nGlória perene será para mim!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim, há de ser glória pra mim! \nGlória pra mim! Glória pra mim! \nQuando puder o seu rosto mirar, \nOh, há de ser grande glória pra mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando, por graça do seu grande amor, \nEu alcançar o infinito favor \nDe ir para perto do meu Salvador, \nGlória perene será para mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitos amigos ali hei de achar, \nPaz, alegria, eternal bem-estar; \nMas quando meu Salvador me saudar, \nGlória perene será para mim!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 52,
        titulo: 'HÁ PAZ E ALEGRIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há paz e alegria no reino da luz; \nÀ pátria dos remidos, Jesus nos conduz, \nNo reino dos céus há gozo e paz; \nOs filhos de Deus têm poder veraz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há paz e alegria no reino dos céus; \nOs salvos lá entoam louvores a Deus; \nDai glória a Jesus! Porque nos amou; \nPor nós o Seu sangue Ele derramou!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus tem prometido o Consolador! \nO Espírito Santo o Instruidor; \nTambém prometeu, no reino dos céus, \nUm santo lugar, junto ao nosso Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Firmado na promessa tão grande e eficaz, \nAgora neste mundo desfruto a paz; \nEspero Jesus, nas nuvens descer, \nE da Sua glória vou receber.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ha-paz-alegria-90/',
      ),
      Hino(
        codigo: 53,
        titulo: 'HÁ UMA TERRA ALÉM DO RIO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há uma terra além do rio \nQue chamamos doce e terna. \nQue somente alcançamos pela fé. \nUm a um de entrar havemos, \nNesse lar de bem supremo, \nQuando o Salvador chamar a mim e a ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Campainhas estão a tocar, \nSantos anjos a cantar, \nE há glória, aleluia e resplendor \nNessa terra além do rio \nQue chamamos doce e terna, \nQuando o Salvador chamar a mim e a ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nunca mais pecado e mágoa \nNessa terra do futuro, \nQuando o barco a linda praia alcançar. \nSó teremos alegria, \nOuviremos harmonia, \nQuando o Salvador chamar a mim e a ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando os dias se findarem \nE da morte a dor vencermos, \nQuando o Rei disser ao Espírito:“livre-se\n"Nunca mais angustiados,\nPara sempre consolados,\nQuando o Salvador chamar a mim e a ti.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 54,
        titulo: 'LÁ NO CÉU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há um lar mui feliz lá no céu, \nOnde não há tristeza nem dor, \nOnde os salvos irão habitar, \nNa presença do seu Salvador.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Lá no céu, lá no céu; \nHá um lar mui feliz lá no céu.          (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho amigos fiéis lá no céu, \nQue desfrutam o gozo na luz; \nJá venceram os males daqui \nE lá cantam louvor a Jesus.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Lá no céu, lá no céu; \nTenho amigos fiéis lá no céu.          (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu também vou viver lá no céu, \nE hei de ver quem me deu salvação. \nNão demora o momento de eu ir \nE morar lá naquela mansão.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Lá no céu, lá no céu; \nEu também vou viver lá no céu!       (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nesse lar tão feliz, lá no céu, \nNunca o mal poderá penetrar; \nSó há glória, pureza e prazer \nOnde os salvos por Cristo hão de entrar',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Lá no céu, lá no céu; \nNesse lar tão feliz lá no céu            (Bis)',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/la-no-ceu/',
      ),
      Hino(
        codigo: 55,
        titulo: 'LUGAR DE DELÍCIAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Junto ao trono de Deus preparado \nHá, cristão, um lugar para ti; \nHá perfumes, há gozo exaltado, \nHá delicias profusas ali; \nSim, ali; sim ali, \nDe Seus anjos fiéis rodeado, \nNuma esfera de glória e de luz, \nJunto a Deus nos espera Jesus. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os encantos da terra não podem \nDar idéia do gozo dali; \nSe na terra os prazeres acodem, \nSão prazeres que acabam-se aqui; \nMas ali, mas ali, \nAs venturas eternas concorrem \nCo\'a existência perpétua da luz, \nA torna-nos felizes com Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Conservemos em nossa lembrança, \nAs riquezas do lindo país, \nE guardemos conosco a esperança, \nDe uma vida melhor, mais feliz; \nPois dali, pois dali \nUma voz verdadeira não cansa \nDe oferecer-nos do reino da luz, \nO amor protetor de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se quisermos gozar da ventura \nQue no belo país haverá, \nÉ somente pedir de alma pura, \nQue de graça Jesus nos dará. \nPois dali, pois dali \nTodo cheio de amor, de ternura \nDesse amor que mostrou-nos na cruz, \nNos escuta nos ouve Jesus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/lugar-de-delicias/',
      ),
      Hino(
        codigo: 56,
        titulo: 'MAIS PERTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mais perto quero estar, meu Deus, de Ti, \nInda que seja a dor que me una a Ti! \nSempre hei de suplicar: \nMais perto quero estar,	                  (Bis) \nMeu Deus de Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Andando triste aqui, na solidão, \nPaz e descanso a mim teus braços dão. \nSempre hei de suplicar; \nMais perto quero estar, 	                 (Bis) \nMeu Deus, de Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minha alma cantará a Ti, Senhor, \nCheia de gratidão por teu amor. \nSempre hei de suplicar; \nMais perto quero estar,	                  (Bis) \nMeu Deus, de Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E quando a morte, enfim, me vier chamar, \nCom serafins nos céus irei morar. \nEntão me alegrarei \nPerto de Ti, meu Rei,	                       (Bis) \nMeu Deus, de Ti!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/187-mais-perto-quero-estar/',
      ),
      Hino(
        codigo: 57,
        titulo: 'NÓS RECEBEREMOS LÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nós receberemos lá no Céu \nLá no Céu, o lindo, lindo Céu, \nO outro nome novo, além do véu \nNesse lindo Céu. \nUm nome novo, Um nome novo, \nNós teremos já; \nUm nome novo, um nome novo, \nQuando entrarmos lá.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim receberemos lá no Céu \nLá no Céu, o lindo, lindo Céu, \nO outro nome novo, além do véu, \nNesse lindo Céu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na pedrinha branca, só lerei, \nEsse nome novo de Jesus; \nBranca mais que a neve, a guardarei \nNo reino de Luz. \nPedrinha branca, pedrinha branca, \nNós teremos já; \nPedrinha branca, pedrinha branca, \nQuando entrarmos lá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Larga o mundo, crê em Cristo, e vem! \nO maná escondido é para ti; \nServe, pois, a Deus, tens todo o bem! \nCristo é tudo ali. \nManá escondido, maná escondido, \nNós teremos já; \nManá escondido, maná escondido, \nQuando entrarmos lá.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 58,
        titulo: 'NO CÉU HÁ MUITAS COISAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No céu há muitas muitas coisas que eu anseio ver, \nAs mil belezas, fausto e esplendor, \nMas ao fruir das celestiais moradas: o prazer, \nPrimeiro quero ver meu Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Primeiro quero ver meu Salvador, \nSim, antes dos queridos ao redor, \nE então por longos dias, que doce alegria \nEu quero ver primeiro o Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As ruas de ouro eu quero ver, \nE os seus novéis portais \nEu quero ver os paços celestiais \nA árvore da vida e o lindo rio do Senhor; \nEu quero ver primeiro o Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu quero ver mamãe, estar com ela no jardim, \nDos dias idos lembrarei co\'amor; \nQueridos quero ver, os quais partiram antes de mim, \nMas, quero ver primeiro o Salvador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/primeiro-quero-ver-meu-salvador/',
      ),
      Hino(
        codigo: 59,
        titulo: 'NA MANSÃO DO SALVADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá na mansão do Salvador \nNão há, jamais, tribulação; \nNenhum pesar, nenhuma dor, \nQue me quebrante o coração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ali não há tristezas e dor, \nNenhum pesar, nem aflição; \nQuando eu estiver morando lá \nDirei: Não há tribulação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'P\'ra mim é triste estar aqui, \nMui longe, sim, do Salvador, \nPois moram já com Ele ali, \nOs salvos pelo Seu amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Perfeito amor encontrarei, \nLá na mansão do meu Senhor, \nCompleta paz, ali terei, \nPois me dará o Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Estando lá, eu gozarei \nDe toda a bênção divinal; \nTambém, com Cristo reinarei, \nNa Sua glória eternal.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 60,
        titulo: 'NO CÉU NÃO ENTRA PECADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No Céu não entra pecado \nFadiga, tristeza, nem dor; \nNão há coração quebrantado, \nPois todos são cheios de amor, \nAs nuvens da vida terrestre \nNão podem a glória ofuscar \nDo reino de gozo celeste, \nQue Deus quis p\'ra mim preparar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Irei eu p\'ra linda cidade,\nJesus me dará um lugar, \nCo\'os crentes de todas idades, \nA Deus hei de sempre louvar. \nDo Céu tenho muitas saudades, \nDas glórias que lá hei de ver;. \nOh! Que gozo vou ter, \nQuando eu vir meu Senhor, \nRodeado de grande esplendor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pagar não é necessário \nA casa, que lá hei de ter; \nE meu eternal vestuário, \nNo Céu, nunca vai se romper. \nJamais viverei em pobreza, \nAflito, no meu santo lar, \nAli há bastante riqueza, \nDa qual poderei desfrutar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No Céu o luto é banido, \nEnterros não hão de passar; \nSepulcros jamais são erguidos, \nLá mortos não vou encontrar. \nOs velhos serão transformados; \nMudados nós vamos ficar, \nQuais astros por Deus espalhados \nNo Céu, para sempre brilhar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/422-no-ceu-nao-entra-pecado/',
      ),
      Hino(
        codigo: 61,
        titulo: 'OH! QUE SAUDOSA LEMBRANÇA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que saudosa lembrança \nTenho de ti, ó Sião! \nTerra que eu tanto amo, \nPois és do meu coração; \nEu para ti voarei, \nQuando o Senhor meu voltar, \nPois ele foi para o Céu \nE breve vem me buscar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim, eu porfiarei por essa terra de além \nE lá terminarei as minhas lutas de aquém; \nLá está meu bom Senhor, ao qual eu desejo ver. \nEle é tudo pra mim e sem Ele eu não passo viver.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bela, mui bela é a esperança \nDos que vigiam por ti, \nPois eles recebem forças, \nQue só se encontram ali; \nOs que procuram chegar \nAo teu regaço, ó Sião, \nLivres serão de pecar \nE de toda a tentação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Diz a Sagrada Escritura \nQue são formosos os pés \nDaqueles que boas novas \nLevam para os infiéis; \nE, se tão belo é falar \nDessas grandezas, aqui, \nQue não será o gozar \nA graça que existe ali!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/02-oh-que-saudosa-lembranca/',
      ),
      Hino(
        codigo: 62,
        titulo: 'O PEREGRINO NA TERRA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou peregrino na terra \nE longe estou do meu lar, \nMinh\'alma anelante espera \nQue Cristo a venha buscar; \nAqui só há descrença, \nAs lutas não têm fim, \nMas de Jesus, a presença, \nGlória será para mim!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'No Céu de luz vou descansar, \nCom meu Jesus hei de morar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Cristo tendo já crido, \nSó pela fé viverei, \nPois Deus me tem prometido, \nQue no Céu descansarei! \nEu tenho permanente \nO bom Consolador, \nGuiando-me brandamente \nA fonte viva de amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Embora às vezes o crente \nAs dores sofra da cruz, \nGozo terá permanente, \nQuando no Céu vir Jesus \nDe glória coroado \nNo trono divinal, \nPor anjos sempre louvado; \nNum coro celestial.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-peregrino-na-terra/',
      ),
      Hino(
        codigo: 63,
        titulo: 'PÁTRIA CELESTIAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pátria minha, por ti suspiro; \nQuando no teu bom descanso chegarei? \nOs patriarcas, de Deus amigos, \nE os bons profetas, fiéis, antigos, \nJá entraram na tua glória, \nContemplando, em esplendor, o grande Rei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os remidos, tão perseguidos, \nPelo sangue já venceram o Dragão; \nPor Jesus Cristo são vencedores, \nE agora cantam os seus louvores \nPátria santa, desejo ver-te, \nVer com Cristo a redimida multidão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá, o rio das águas vivas, \nSai do trono do Cordeiro e do Senhor; \nÉ luminoso desde a nascente, \nComo cristal é resplandecente; \nPela margem daquele rio \nAndam os remidos com o Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não há pranto na minha pátria, \nNela nunca se dará separação; \nAli o trono de Deus descansa, \nAli teremos real bonança; \nOs remidos da minha pátria \nCom Jesus eternamente reinarão.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/patria-celestial/',
      ),
      Hino(
        codigo: 64,
        titulo: 'QUERIDO LAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De todas as terras irão chegar \nUm a um! um a um! \nNa eterna mansão, para ali morar, \nSim, um a um! \nVestidos de trajes celestiais, \nBem longe do mundo e dos tristes ais, \nDesfrutam com Cristo a perfeita paz, \nGozando uma vida que satisfaz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'No eterno lar, querido lar, \nEi-los entrando um a um! \nNo eterno lar, no lindo lar, \nSim, um a um!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Também nós havemos de ali chegar, \nUm a um! um a um! \nDa glória dos salvos compartilhar, \nSim, um a um! \nIrão uns entrar nesse lar de além \nSem muito sofrer no viver de aquém, \nMas outros terão de lutar, sofrer, \nPorém hão de entrar sem desfalecer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Humildes, submissos, a Ti, Senhor, \nTodos nós! todos nós! \nQueremos viver sob o teu favor, \nSim, todos nós! \nContigo almejamos participar \nDa vida gloriosa do eterno lar. \nÓ Tu, que dominas a terra e os céus, \nTransporta-nos todos nos braços teus!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 65,
        titulo: 'SEMPRE FIRME',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minha morada, Jesus, assegura, \nPaz e conforto na luta feroz; \nDá-me teu braço, transporta-me à altura \nOnde escutar poderei tua voz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem dar-me paz, ó meu Jesus, \nDá-me teu braço, ó Cristo! \nVou perecendo longe da cruz, \nE eu em clamar insisto!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Triste, procuro refúgio ao teu lado, \nVolta-me a paz, o descanso me vem; \nQuando na terra me achar desprezado \nGlória terei noutra pátria de além.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando da morte cercar-me a tristeza \nFinda a jornada do mundo cruel, \nCerto terei nesse dia a certeza \nDe ir me alegrar sob imenso doce!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 66,
        titulo: 'SIÃO, CIDADE TÃO LINDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sião, cidade tão linda, \nNela almejamos morar, \nPois Cristo nos prometeu \nUm dia vir-nos buscar, \nPara levar-nos à glória \nDaquela linda mansão \nCantando a grande vitória, \nOs remidos com Cristo \nNo céu entrarão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sião, ó Sião! \nPátria querida de amor. \nÉs a mais bela, sublime mansão \nEm ti não há pranto e nem dor \nSião! ó Sião \nNem sol nem luzeiro haverá, \nMas o cordeiro bendito \nNa glória do Altíssimo te iluminará',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá em Sião nos espera \nUma grande multidão, \nDos que lavaram suas vestes \nNo sangue da expiação; \nRenunciaram suas vidas \nPara em Sião ir morar. \nPois só as almas remidas \nPor Cristo no céu \nTem poder de entrar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/cidade-de-deus/',
      ),
      Hino(
        codigo: 67,
        titulo: 'TERRA FELIZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu avisto uma terra feliz, \nOnde irei para sempre morar; \nHá mansões nesse lindo país, \nQue Jesus foi pra nós preparar.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Vou morar, vou morar                   (Bis) \nNessa terra, celeste porvir!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cantarei nesse lindo país \nBelos hinos ao meu Salvador, \nPois ali viverei bem feliz, \nSem angústias, tristezas, nem dor.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Vou cantar, vou cantar                 (Bis) \nNessa terra, celeste porvir',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deixarei este mundo afinal \nPara ir a Jesus adorar; \nNessa linda cidade real, \nMil venturas sem fim vou gozar.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Vou gozar, vou gozar                    (Bis) \nNessa terra, celeste porvir',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/terra-feliz/',
      ),
      Hino(
        codigo: 68,
        titulo: 'TUDO FELIZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se infeliz nos corre a vida terreal, \nTemos de deixá-la um dia, \nPara irmos logo ao lar celestial, \nOnde tudo é mui feliz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vamos ver Jesus ali, \nSua santa paz fruir, \nE com Êle estar, \nSeu rosto contemplar, \nGrande gozo desfrutar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitos são os males nesta vida aqui; \nTemos de deixá-la um dia; \nAlegria plena vamos ter ali, \nOnde tudo é mui feliz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vitória certa que Jesus nos dá, \nHemos de gozá-la um dia; \nA peleja finda, calma nos virá \nOnde tudo é mui feliz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Todos os remidos se conhecerão, \nSim, ali no céu, um dia; \nNa alegria santa sempre viverão, \nOnde tudo é muito feliz.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 69,
        titulo: 'TERRA DE DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deste mundo, sim, além, há um país de luz; \nÓ! Não queres ir lá? O! Não queres ir lá? \nOnde as trevas não se vêem, pois brilha ali Jesus; \nO! Não queres ir lá? O! Não queres ir lá?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Terra de Jesus, terra de amor! \nOh! Não queres ir lá? Oh! Não queres ir lá? \nOnde brilha a luz do meu Salvador, \nOh! Não queres ir lá? Oh! Não queres ir lá?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelas portas de fulgor, não pode o mal entrar; \nÓ! Não queres ir lá? O! Não queres ir lá? \nNem a morte, luto ou dor no Céu terão lugar, \nO! Não queres ir lá? O! Não queres ir lá?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que divinal mansão Jesus nos preparou! \nO! Não queres ir lá? O! Não queres ir lá? \nOnde todos os irmãos vão ver Quem os salvou, \nO! Não queres ir lá? O! Não queres ir lá?',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 70,
        titulo: 'VOU Ó PÁTRIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vou à pátria eu, peregrino, \nA viver eternamente com Jesus, \nQue me marcava feliz destino \nNo dia quando por mim morreu na cruz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vou à pátria, eu, peregrino. \nA viver eternamente com Jesus.             (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dor e pena, tristeza e morte \nNunca mais, não, nunca me interrompem lá \nDesfruta sempre de Cristo a sorte \nE ao Deus bendito minha alma louvará;',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Terra santa, formosa e pura, \nSalvo por Jesus eu cantarei em ti; \nFelicidade, paz e doçura, \nTerei na glória! Ah, quando irei daqui?',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/eder-g-de-zen/vou-a-patria/',
      ),
      Hino(
        codigo: 71,
        titulo: 'ADORAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Adorai o Rei do Universo! \nTerra e céus, cantai o Seu louvor! \nTodo o ser no grande mar submerso, \nLouve ao Dominador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Todos juntos O louvemos! \nGrande Salvador e Redentor! \nTodos O louvemos! \nRégio Dominador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Adorai-O, anjos poderosos, \nVós que Sua glória contemplais! \nVós, remidos, já vitoriosos; \nGraças, rendei-Lhe mais!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sol, e lua, coros estelares, \nSua majestade anunciai, \nHostes grandes, centos de milhares, \nO Seu poder mostrai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ventos! Chuvas! Raios! Trovoadas! \nRevelai o grande Criador! \nVós dizeis, ó serras elevadas, \nQuão grande é meu Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Altos cedros! Grama verdejante! \nEsta sinfonia aumentai; \nAves, vermes, todo o ser gigante; \nGratos a Deus louvai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Homens! Jovens! Velhos e meninos! \nAdorai ao vosso Redentor! \nReis e sábios, grandes, pequeninos, \nDai-Lhe veraz louvor!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/124-adoracao/',
      ),
      Hino(
        codigo: 72,
        titulo: 'ALÉM DO NOSSO ENTENDIMENTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muito além do nosso entendimento, \nAlto mais que todo o pensamento, \nGlorioso em seu sublime intento, \nÉ o amor de Deus, sem par.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Grande amor! Amor de Deus! \nEnche a terra e enche os Céus! \nGrande amor! Amor que abrange \nA todo o mundo e atinge a mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fez um sacrifício infinito, \nDum valor imenso inaudito; \nDando-nos o seu Filho bendito; \nCalculai o amor de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Grande, foi mui grande o meu pecado; \nTriste, perigoso o meu estado; \nMas o amor que nunca foi sondado \nMe salvou o amor de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Foi Quem perdoou os pecadores, \nRogos atendeu de malfeitores, \nQuem sarou os pobres sofredores, \nEsse imenso amor de Deus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/alem-do-nosso-entendimento/',
      ),
      Hino(
        codigo: 73,
        titulo: 'A DEUS DEMOS GLÓRIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Deus demos glória; com grande amor \nSeu filho bendito a nós todos deu; \nE a graça concede ao mais vil pecador \nAbrindo-lhe a porta de entrada no Céu.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Exultai! Exultai! Vinde todos louvar \nA Jesus Salvador! A Jesus Redentor! \nA Deus demos glória, porquanto do Céu \nSeu filho bendito a nós todos deu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! graça real! foi assim que Jesus, \nMorrendo seu sangue por nós derramou \nHerança nos Céus, com os santos em luz \nComprou-nos Jesus, pois o preço pagou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A crer vos convida tal rasgo de amor \nNos merecimentos do Filho de Deus; \nE quem pois confia no seu Salvador, \nVai vê-lo sentado na glória dos Céus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/corinhos-evangelicos/a-deus-demos-gloria/',
      ),
      Hino(
        codigo: 74,
        titulo: 'CASTELO FORTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Castelo forte é nosso Deus, \nEspada e bom escudo; \nCom seu poder defende os seus \nEm todo o transe agudo. \nCom fúria pertinaz \nPersegue Satanás, \nCom ânimo cruel; \nAstuto e mui rebel \nIgual não há na terra.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A nossa força nada faz; \nO homem está perdido; \nMas nosso Deus socorro traz, \nNo filho escolhido. \nSabeis quem é? Jesus, \nO que venceu na cruz, \nSenhor dos altos Céus; \nE, sendo o próprio Deus \nTriunfa na batalha.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se nos quisessem devorar \nDemônios não contados, \nNão nos podiam derrotar, \nNem ver-nos assustados. \nO príncipe do mal, \nCom rosto infernal, \nJá condenado está; \nVencido cairá. \nPor uma só palavra.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que a palavra ficará, \nSabemos com certeza, \nE nada nos assustará, \nCom Cristo por defesa. \nSe temos de perder \nOs filhos, bens, mulher \nEmbora a vida vá, \nPor nós Jesus está \nE dar-nos-á seu reino',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/castelo-forte/',
      ),
      Hino(
        codigo: 75,
        titulo: 'DEUS ENVIOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus enviou seu filho amado \nPra me salvar e perdoar \nNa cruz morreu por meus pecados \nMas, ressurgiu e vivo com o Pai está.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Porque Ele vive, posso crer no amanhã \nPorque Ele vive temor não há \nMas eu bem sei, eu sei que minha vida \nEstá nas mãos de meu Jesus que vivo está.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E quando enfim chegar a hora \nEm que a morte enfrentarei \nSei que então terei vitória \nVerei na glória o meu Jesus que vivo está.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/porque-ele-vive/versao-4.html',
      ),
      Hino(
        codigo: 76,
        titulo: 'DEUS VELARÁ POR TI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não desanimes, Deus proverá; \nDeus velará por ti; \nSob Suas asas te acolherá; \nDeus velará por ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deus cuidará de ti, \nNo teu viver, no teu sofrer \nSeu olhar te acompanhará; \nDeus velará por ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se o coração palpitar de dor, \nDeus velará por ti; \nTu já provaste Seu terno amor, \nDeus velará por ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nos desalentos, nas provações \nDeus velará por ti; \nLembra-te dEle nas tentações \nDeus velará por ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo o que pedes. Ele fará; \nDeus velará por ti; \nE o que precisas não negará. \nDeus velará por ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como estiveres, não temas, vem! \nDeus velará por ti; \nEle te entende, te ama bem! \nDeus velará por ti.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/deus-velara-por-ti/',
      ),
      Hino(
        codigo: 77,
        titulo: 'DEUS VIVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há um mistério nesta Igreja, \nHá um silêncio de oração. \nHá um milagre acontecendo \nNo meio da congregação \nEu vejo um anjo descendo, \nCom sua espada de poder \nÉ o mensageiro do Senhor, \nQue veio pra nos socorrer.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deus vivo, oh! Deus Vivo, \nQuem é salvo sente, \nSeu amor presente \nPois estás aqui, \nDeus vivo, oh! Deus vivo, \nTorna tudo novo \nE abençoa o povo \nQue confia em Ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há uma alegria em nossas vidas, \nHá um temor no coração \nAs nossas mãos estão unidas \nE Deus visita cada irmão \nDos nossos olhos correm lágrimas \nE nós sentimos operar, \nO nosso Deus está aqui, \nSeu santo nome é Jeová.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/andrea-fontes/deus-vivo/',
      ),
      Hino(
        codigo: 78,
        titulo: 'DEUS CUIDARÁ DE TI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aflito e triste coração, \nDeus cuidará de ti; \nPor ti opera a sua mão \nQue cuidará de ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deus cuidará de ti, \nEm cada dia proverá; \nSim, cuidará de ti, \nDeus cuidará de ti,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na dor cruel, na provação, \nDeus cuidará de ti; \nSocorro dá e salvação, \nPois cuidará de ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A tua fé Deus quer provar, \nMas cuidará de ti; \nO teu amor quer aumentar, \nE cuidará de ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nos seus tesouros tudo tens, \nDeus cuidará de ti; \nTerrestres e celestes bens, \nE cuidará de ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O que é mister te pode dar \nQuem cuidará de ti; \nNos braços seus te sustentar, \nPois cuidará de ti.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/deus-cuidara-de-ti/',
      ),
      Hino(
        codigo: 79,
        titulo: 'DESLUMBRANTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se nos cega o sol ardente, \nQuando visto em seu fulgor, \nQuem contemplará Aquele \nQue do Sol é criador? \nPatriarcas, nem profetas \nO chegaram a avistar, \nNem Adão chegou a vê-Lo, \nAntes mesmo de pecar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Luz, pra a qual o sol é trevas, \nQuem Te pode contemplar? \nNossos olhos nus, humanos, \nNão Te podem encarar. \nFogo em cima da arca santa, \nSarça ardente no Sinai, \nSão figuras só, da glória \nDo Senhor, do eterno Pai.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para termos nós com Ele \nFranca e doce comunhão \nCristo, o Filho, fez-se carne, \nFez-se nossa redenção. \nPara que na glória eterna \nNos miremo-Lo sem véu, \nCristo padeceu a morte, \nNova entrada abrindo ao céu.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/hino-96/',
      ),
      Hino(
        codigo: 80,
        titulo: 'FALA, FALA, SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fala, fala, Senhor, nesta hora, \nQue ansioso te quero ouvir; \nTeu falar dá valor e restaura, \nE mais sábio me faz no porvir.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Bendito o Teu Nome em eterno, \nQue Tu falas a quem escutar, \nDe saúde e repouso superno, \nDe alegria e paz eternal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fala, fala, Senhor, que conservo \nTuas palavras de vida e vigor; \nEstou pronto a seguir-Te com zelo, \nPelas Tuas veredas de amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fala, fala, Senhor, que eu ouço \nTuas palavras com todo fervor, \nPois conduzem ao eterno repouso, \nSão conselhos mui ricos de amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/fala-fala-senhor/',
      ),
      Hino(
        codigo: 81,
        titulo: 'FIGUEIRA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ainda que a figueira não floresça, \nAinda que a videira não dê flor, \nAinda que o rebanho meu pereça, \nEu sempre ao Fiel darei louvor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se for preciso estar sozinho sempre \nSem nunca ter alguém para cuidar \nTemendo amanhecer ainda noite, \nTeu nome nos meus lábios há de estar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Então me alegrarei no meu Senhor. \nPerdão, hó Pai, teu servo se exaltou. \nTu sabes quantas vezes me faltou louvor \nE abrindo a flor meu cântico parou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mas teu amor é como orvalhar \nE Teu favor sempre há de me cingir. \nDe novo, então, ensina-me a cantar; \nMesmo se a figueira não florir.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 82,
        titulo: 'GRATA NOVA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Grata nova Deus proclama \nHoje, ao mundo pecador \nDoce nova revelada, \nLá na cruz do Salvador; \nCego e desviado; o homem, \nDos caminhos do Senhor, \nDesconhece e desconfia \nDeste Deus, o Deus de amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Grata nova, doce nova, \nVem dos lábios do Senhor, \nEscutai com alegria: \n“Deus é luz, Deus é amor”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com ofertas e obras mortas, \nSacrifícios sem valor, \nEnganado, pensa o homem, \nPropiciar Seu Criador, \nMeios de salvar-se inventa; \nClama, roga em seu favor, \nA supostos mediadores, \nDesprezando o Deus de amor. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Luz divina, resplandece! \nMostra ao triste pecador, \nQue na cruz estão unidos \nA justiça e o amor. \nFala aos corações feridos, \nMostra-te, Deus Salvador; \nE sem fim, proclamaremos: \n“Deus é luz! Deus é amor!” ',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/grata-nova/',
      ),
      Hino(
        codigo: 83,
        titulo: 'LOUVOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos nós louvar a Deus, \nVamos, vamos; \nAo Senhor de toda luz, \nSanto, santo! \nCantem, louvem lá nos céus \nNosso Deus e Rei Jesus! \nExaltado seja Deus, \nSanto, santo!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Exaltado, seja o nosso Deus e Pai! \nExaltado, para sempre, oh! exaltai! \nCantem, louvem lá nos céus \nNosso Deus e Rei Jesus! \nExaltado seja Deus, \nSanto, santo!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus, o nosso eterno Pai, \nSanto, santo! \nDeu-nos bênçãos por Jesus, \nVede, vede! \nAo Senhor glorificai, \nVós, os salvos pela cruz, \nSim, conosco glória dai, \nVinde, vinde!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Exaltemos nosso Deus, \nSanto, santo! \nExaltemos com fervor, \nHoje, hoje! \nTributemos todos nós \nHinos santos de louvor, \nSim, louvor em alta voz, \nHoje, hoje!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao Senhor, de todo amor, \nDeus de glória, \nDeus de luz e Deus de paz, \nCantem glória! \nHoje nós também louvor \nVimos dar-te, que te apraz, \nPois nos deste, Salvador, \nMuitas bênçãos!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/385-cc-louvor/original.html',
      ),
      Hino(
        codigo: 84,
        titulo: 'LOUVAMOS-TE, Ó DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvamos-Te, Ó Deus, \nPelo dom de Jesus, \nQue por nós pecadores, \nMorreu na cruz ',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Aleluia! Toda glória \nTe rendemos sem fim. \nAleluia! Tua graça, \nImploramos, amém.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvamos-Te, Ó Deus, \nPelo Espírito de Luz. \nQue as trevas dissipa, \nE a Cristo conduz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvamos-Te, Senhor. \nÓ Cordeiro de Deus; \nFoste morto, mas vives \nEterno nos Céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem encher-nos, Ó Deus, \nDe Celeste ardor \nE fazer-nos sentir \nTão imenso amor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-para-culto-cristao/louvamos-te-o-deus/',
      ),
      Hino(
        codigo: 85,
        titulo: 'MARAVILHAS DIVINAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao Deus de amor e de imensa bondade, \nCom voz de júbilo vinde e aclamai; \nom coração transbordante de graças, \nSeu grande amor todos vinde e louvai.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'No céu, na terra, que maravilhas \nVai operando o poder do Senhor! \nMas seu amor aos homens perdidos \nDas maravilhas é sempre a maior!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já nossos pais nos contaram a glória \nDe Deus, falando com muito prazer, \nQue nas tristezas, nos grandes perigos, \nEle os salvou por seu grande poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hoje também nós bem alto cantamos \nQue as orações Ele nos atendeu; \nSeu forte braço, que é tão compassivo, \nEm nosso auxilio Ele sempre estendeu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como até hoje e daqui para sempre, \nEle será nosso eterno poder, \nNosso castelo bem forte e seguro, \nE nossa fonte de excelso prazer.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/7-maravilhas-divinas/',
      ),
      Hino(
        codigo: 86,
        titulo: 'NINGUÉM SE ESCONDE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ninguém se esconde da presença de Deus, \nEsteja aonde estiver Ele vê \nSe debaixo das águas procurar te esconder, \nNão adianta nada, porque tudo Deus vê.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deus está vendo como chama de fogo \nO que andas fazendo escondido entre o povo \nNão se pode esconder da presença de Deus \nPorque dos altos céus, \nTudo, tudo Deus vê.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se entre as grandes nuvens procurar te esconder; \nIsto será inútil porque tudo Deus vê \nSe entre as grandes rochas procurar te esconder \nSeu olhar como tocha, está sempre a te ver!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus é incomparável em justiça e saber, \nDono de todas as coisas, Senhor de todo ser, \nTu só podes esconder é do homem carnal \nMesmo assim Deus revela ao espiritual.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 87,
        titulo: 'O GRANDE EU SOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não perturbeis o coração, \nPorque Eu sempre sou fiel; \nEu fecho a boca do “leão”, \nNa cova estou com Daniel.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sou Eu aquele, o grande “EU SOU” \nE, onde estais, também estou; \nNão disse, Eu, há muito já: \n“Pedi, pedi... dar-se-vos á”? \nPedi com fé e com fervor \nE vos darei o Consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem tem a fé de Abraão, \nO mundo sempre há de vencer; \nQuem quer ter firme o coração, \nPrecisa igualmente crer',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um terremoto e vento, após, \nDo céu, um fogo e mui furor, \nOuviu Elias a minha voz, \nVoz do Eterno, voz de amor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um certo dia, Estevão viu \nO céu aberto e viu-me a mim, \nApedrejado, sucumbiu, \nMas, foi fiel, até o fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Firmado em mim, Rocha Eternal, \nAssim jamais o crente cai; \nBuscai o dom celestial, \nQue vem da casa de meu Pai.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-grande-eu-sou/indefinida-2.html',
      ),
      Hino(
        codigo: 88,
        titulo: 'O SENHOR DA CEIFA CHAMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Senhor da ceifa está chamando; \n“Quem que ir por Mim a procurar \nAlmas que no mundo vão chorando \nSem da salvação participar?”',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Fala, Deus! Fala Deus! \nToca-me com brasa do altar; \nFala Deus! Fala Deus! \nSim, alegre, atendo ao Teu mandar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O profeta a Deus se aproximando, \nConsidera-se um pecador, \nMas, o fogo santo o queimando, \nTorna-o útil para seu Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitos são os que vão expirando \nSem ter esperança de ver Deus. \nVai depressa lhes anunciando, \nQue Jesus os leva para os céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Breve, os trabalhos serão findos, \nBênçãos vão os servos desfrutar; \nE Jesus os saudará: “Bem-Vindos”, \nEsta glória espero alcançar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-senhor-da-ceifa-chama/',
      ),
      Hino(
        codigo: 89,
        titulo: 'PLANO DE DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus tem um plano em cada criatura \nAos astros Ele dá o céu \nA cada rio Ele dá um leito \nE um caminho para mim traçou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A minha vida eu entrego a Deus \nPois o seu filho entregou por mim \nNão importa onde for \nSeguirei meu Senhor \nSobre terra ou mar \nOnde Deus mandar, irei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E o seu querer encontro paz na Bíblia \nE bênçãos que jamais gozei \nEmbora tenha lutas e tristezas \nTenho a fé que Deus me guiará.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/victorino-silva/deus-tem-um-plano/',
      ),
      Hino(
        codigo: 90,
        titulo: 'SENHOR MEU DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Senhor, meu Deus, quando eu maravilhado, \nParo a pensar no teu grandioso ser. \nVejo a tormenta, o céu estrelado, \nA proclamar ao mundo o teu poder.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Então minh\'alma canta a ti, Senhor; \nGrandioso és Tu, grandioso és Tu! \nEntão minh\'alma canta a ti, Senhor; \nGrandioso és Tu, grandioso és Tu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E quando penso em como Deus me ama, \nQue, em meu lugar, Jesus na cruz morreu \nA gratidão meu coração proclama, \nPois foi por mim que Ele padeceu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E quando enfim, eu for ao céu subindo, \nContemplarei a glória do Senhor; \nAdorarei, com meu amor infindo, \nA quem mostrou por mim tão grande amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-aleluia/senhor-meu-deus-/',
      ),
      Hino(
        codigo: 91,
        titulo: 'SALMO 51',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Conforme a tua infinita graça, \nÓ Pai perdoa a minha transgressão, \nFaz-me sentir mais uma vez a graça; \nE dá-me tua paz no coração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Mais uma vez eu sinto o meu pecado \nQue é contra ti ó Pai, ó Pai de amor! \nMinh\'alma pede a tua alegria \nRenova em mim o teu amor ó meu Senhor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu coração a ti eu ofereço \nPerdão te imploro meu Senhor e Rei \nConforme a tua infinita graça \nA misericórdia, sim, alcançarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Deus bendito, eu te peço neste momento \nTeu paternal cuidado sobre mim \nQuero sentir mais uma vez a graça \nLouvar-te quero, até o fim.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/icr/conforme-a-tua-infinita-graca/',
      ),
      Hino(
        codigo: 92,
        titulo: 'SANTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santo! Santo! Santo! Deus onipotente! \nCedo de manhã cantaremos teu louvor. \nSanto! Santo! Santo! Deus Jeová triúno. \nÉs um só Deus, excelso Criador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santo! Santo! Santo! Todos os remidos, \nJuntos com os anjos, proclamam teu louvor. \nAntes de formar-se o firmamento e a terra, \nEras e sempre és e hás de ser, Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santo! Santo! Santo! Nós os pecadores \nNão podemos ver tua glória sem tremor. \nTu somente és santo, não há nenhum outro, \nPuro e perfeito, excelso Benfeitor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santo! Santo! Santo! Deus onipotente! \nTuas obras louvam teu nome com fervor. \nSanto! Santo! Santo! justo e compassivo, \nÉs um só Deus, supremo Criador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/santo-santo/',
      ),
      Hino(
        codigo: 93,
        titulo: 'GLÓRIA AO SALVADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chegado à cruz do meu bom Senhor \nProstrado aos pés do Redentor, \nEle ouviu todo meu clamor \nGlória ao Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Glória ao Salvador! \nGlória ao Salvador! \nAgora sei que Ele me salvou, \nGlória ao Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que maravilha! Jesus me amou, \nTudo de graça me perdoou; \nQuebrou meus laços e me livrou; \nGlória ao Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Junto à cruz, inda há lugar, \nVem, ó aflito, sem demorar, \nCristo está pronto p\'ra te salvar, \nVinde ao Salvador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/gloria-ao-salvador/completa.html',
      ),
      Hino(
        codigo: 94,
        titulo: 'INABALÁVEL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A cruz ainda firme está: Aleluia! Aleluia! \nE para sempre ficará; Aleluia! Aleluia! \nPois o inferno trabalhou, \nSatanás rancor mostrou, \nMas ninguém a derribou! \nAleluia pela cruz!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Aleluia! Aleluia! \nAleluia por Jesus! \nAleluia! Aleluia! \nQuem triunfa é só Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É sempre vencedora a cruz; Aleluia! Aleluia! \nPois testifica de Jesus; Aleluia! Aleluia! \nSua graça ali brilhou, \nSeu amor se nos mostrou, \nPlena paz se efetuou! \nAleluia pela cruz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ali rendeu o Salvador - Aleluia! Aleluia! \nA vida pelo pecador; Aleluia! Aleluia! \nFoi ali que triunfou, \nSalvação nos outorgou, \nSim, o céu nos conquistou! \nAleluia pela cruz!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/inabalavel/',
      ),
      Hino(
        codigo: 95,
        titulo: 'LOUVAI A JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvai a Jesus, amoroso; \nNa cruz os pecados levou, \nQue nos enche de santo gozo; \nCom sangue o Céu nos ganhou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ao meu Senhor, \nQue tenho no meu coração, \nEu dou louvor, \nPois Ele me deu salvação',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvai a Jesus poderoso, \nQue veio livrar da prisão \nUm povo cativo, medroso, \nQue não tinha consolação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvai a Jesus, vosso guia \nNo mundo de tribulação; \nE não tem temor, quem confia \nEm Deus, mas real proteção.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvai a Jesus, dai-Lhe glória, \nPois Rei e Senhor Ele é; \nNa cruz nos ganhou a vitória; \nVencei com Jesus pela fé.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/louvai-jesus/',
      ),
      Hino(
        codigo: 96,
        titulo: 'PLENA PAZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Plena paz e santo gozo, \nTenho em ti, ó meu Jesus! \nPois eu cri em Tua morte sobre a Cruz; \nNo Senhor só confiando \nNeste mundo viverei, \nEntoando aleluias ao meu Rei!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! glória ao meu Jesus! \nPois é digno de louvor, \nÉ meu Rei, meu bom Pastor, e meu Senhor. \nComo os anjos, que O louvam, \nEu também O louvarei, \nEntoando aleluias ao meu Rei!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O amor de Jesus Cristo \nÉ mui grande para mim, \nPois Sua graça me encheu de amor sem fim. \nMeu Jesus foi para a glória, \nMas um dia eu O verei, \nEntoando aleluias ao meu Rei!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Este mundo não deseja \nTão bondoso Salvador, \nNão sabendo agradecer Seu grande amor \nEu, porém, estou gozando \nDo favor da Sua lei, \nEntoando aleluias ao meu Rei!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando o povo israelita \nCom Jesus se consertar, \nDando glória ao Seu nome, sem cessar. \nNesse tempo céu e terra \nHão de ser a mesma grei, \nEntoando aleluia ao meu Rei!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/plena-paz/',
      ),
      Hino(
        codigo: 97,
        titulo: 'SAUDAI JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Saudai o nome de Jesus! \nArcanjos, vos prostrai; \nArcanjos, vos prostrai; \nAo Filho do eterno Deus, \nCom glória, glória, \nGlória, glória, \nCom glória, coroai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó escolhida geração \nDo bom e eterno Pai, \nDo bom e eterno Pai; \nAo grande Autor da salvação, \nCom glória, glória, \nGlória, glória, \nCom glória, coroai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó perdoados, cujo amor \nBem triunfante vai, \nBem triunfante vai, \nAo Deus Varão, Conquistador, \nCom glória, glória, \nGlória, glória, \nCom glória coroai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó raças, tribos e nações \nAo Rei dos reis honrai! \nAo Rei dos reis honrai! \nA quem quebrou vossos grilhões, \nCom glória, glória, \nGlória, glória, \nCom glória coroai!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/saudai-jesus/',
      ),
      Hino(
        codigo: 98,
        titulo: 'VEM, CELESTE REDENTOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Senhor, do bem a fonte, \nVem, celeste Redentor, \nAjudar-me a entoar-te \nDignos hinos de louvor; \nTu, Jesus, por mim morreste, \nQuero só p\'ra Ti viver; \nQuero em todos os momentos \nTua bênção receber.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Era pobre desgarrado \nQuando Cristo me buscou; \nPara me salvar do inferno \nO Seu sangue derramou; \nEm Sua morte tão penosa, \nPaz, perdão e vida achei, \nE com Ele eternamente \nSua glória fruirei',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De tua graça, ó meu Amado, \nSou continuo devedor; \nMais e mais a Ti me atrai \nPelo Teu divino amor; \nSou ingrato, e bem conheço, \nPeço, meu Senhor, perdão; \nTira-me do vil pecado, \nRege Tu meu coração.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vem-celeste-redentor/',
      ),
      Hino(
        codigo: 99,
        titulo: 'VIVA CRISTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Viva Cristo, eternal riqueza, \nMeu escudo, vida e firmeza, \nSua graça - Oh! me faça \nReluzir no Seu amor. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Viva Cristo, Rocha já eleita, \nA verdade pura e perfeita; \nMeu sustento - Gran contento, \nQue me faz andar na luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Viva Cristo, minha eterna sorte; \nMeu tesouro é depois da morte; \nMe conforta, me exorta \nA viver em perfeição.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Viva Cristo, o Senhor da glória \nQue aos crentes sempre dá vitória, \nE a vida prometida, \nQue, p\'ra nós ganhou na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Viva Cristo, Condutor dos santos! \nViva Cristo, fortemente canto! \nPois me ama e derrama \nNo meu ser, celeste paz.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/viva-cristo-/',
      ),
      Hino(
        codigo: 100,
        titulo: 'MAL SUPÕE AQUELA GENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mal supõe aquela gente, \nQue a Belém quer ir parar. \nQue uma luz tão refulgente \nVai ali brilhar. \nÉ por anjos anunciado, \nE os pastores logo vêem, \nQue esse Rei por Deus mandado, \nNasce em Belém.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vinde, ouvi a doce história, \nQue do Oriente vem; \nO Messias, Rei da glória, \nNasce em Belém!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mundo triste! oh! Despertai! \nTeus grilhões desfeitos são! \nTens a porta franca, aberta; \nSai da vil prisão. \nNão hesites, duvidoso; \nEste dom do Céu provém; \nCristo Todo Poderoso, \nNasce em Belém.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ouve com feliz espanto! \nSurge da vergonha e dor! \nCesse, cesse todo o pranto, \nTens um Salvador! \nGloria a Deus vem promovendo, \nMas aos homens só quer bem; \nPaz, eterna paz trazendo, \nNasce em Belém.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Proclamai a todo mundo, \nToda raça, toda a cor, \nQue Jesus com amor profundo, \nSalva o pecador, \nConfiança plena tende, \nNão desprezará ninguém; \nVinde, os braços vos estende! \nNasce em Belém.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 101,
        titulo: 'NÃO HAVIA LUGAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não teve um palácio no mundo, o Senhor, \nNem honras Lhe deram de Rei Salvador; \nMas a manjedoura só pôde encontrar, \nPorque não havia mais outro lugar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não há lugar pra Cristo \nEm tua vida e lar? \nTerás, então, de ouvir dizer: \n“No céu não tens lugar”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aqui, nos prazeres, tu queres viver, \nGastando os talentos e todo o teu ser? \nPor que continuas no triste pecar? \nPor que não concedes a Cristo lugar?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! quão infelizes as almas sem luz, \nIngratas, perdidas, sem paz, sem Jesus! \nSim, Cristo hoje mesmo deseja habitar \nEm ti, meu amigo. Oh! dá-Lhe lugar!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 102,
        titulo: 'NOITE DE PAZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Noite de paz, noite de amor; \nTudo dorme, em derredor! \nEntre os astros que espargem a luz \nBela, indicando o menino Jesus, \nBrilha a estrela da paz, \nBrilha a estrela da paz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Noite de paz, noite de amor; \nOuve o fiel pastor \nCoros celestes que cantam a paz, \nQue nesta noite sublime nos traz, \nO nosso bom Redentor, \nO nosso bom Redentor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Noite de paz, noite de amor; \nOh! Que belo resplendor, \nPaira no rosto do meigo Jesus! \nE no presépio do mundo, a luz! \nAstro de eterno fulgor, \nAstro de eterno fulgor.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/noite-de-paz/',
      ),
      Hino(
        codigo: 103,
        titulo: 'OH VINDE FIÉIS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Vinde, fiéis, triunfantes, alegres, \nSim, vinde a Belém, já movidos de amor; \nNasceu vosso Rei, o Cristo prometido, \nOh! Vinde adoremos; Oh! Vinde adoremos, \nOh! Vinde, adoremos ao nosso Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Olhai, admirados, a sua humildade, \nOs anjos O louvam com grande fervor, \nPois veio conosco habitar, encarnado; \nOh! vinde adoremos; Oh! vinde adoremos, \nOh! Vinde, adoremos ao nosso Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por nós se humilhou Jesus, o adorável, \nTornando-se pobre, sujeito à dor, \nPra dar-nos de graça a vida sempiterna; \nOh! vinde adoremos; Oh! vinde adoremos, \nOh! Vinde, adoremos ao nosso Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nos Céus adorai-o, vós, coros de anjos, \nE todos na terra lhe rendam louvor. \nA Deus tributemos toda honra e glória; \nOh! vinde adoremos; Oh! vinde adoremos, \nOh! Vinde, adoremos ao nosso Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-para-culto-cristao/90-oh-vinde-fieis/',
      ),
      Hino(
        codigo: 104,
        titulo: 'O PRIMEIRO NATAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A um anjo proclamou o primeiro Natal, \nA uns pobres, pastores ao pé de Belém; \nLá nos campos a guardar, os rebanhos do mal \nNuma noite tão fria e escura também.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Natal, Natal, Natal, Natal! \nÉ nos nascido um Rei Divinal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Uma estrela apareceu, e aos magos guiou, \nNa estrada que para Belém os conduz; \nAfinal sobre Belém, essa estrela parou, \nMesmo sobre a casa, em que estava Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E os magos, com afã e com grande temor, \nDe joelhos entraram naquele lugar; \nOuro, mirra e incenso, vieram lhe dar. \nCom ofertas liberais e com muito valor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-presbiteriano-novo-cantico/o-primeiro-natal/',
      ),
      Hino(
        codigo: 105,
        titulo: 'TUDO É PAZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo é paz! Tudo amor! \nDormem todos em redor; \nEm Belém Jesus nasceu, \nRei da paz, da terra e céu; \nNosso Salvador \nÉ Jesus, Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Glória a Deus! Glória a Deus!” \nCantam anjos lá nos céus; \nBoas-novas de perdão, \nGraça excelsa, salvação; \nProva deste amor \nDá o Redentor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Rei da paz, Rei de amor, \nDeste mundo Criador; \nVinde todos Lhe pedir \nQue nos venha conduzir, \nDêste mundo a luz \nÉ o Senhor Jesus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/noite-de-paz/',
      ),
      Hino(
        codigo: 106,
        titulo: 'A MENSAGEM DA CRUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Rude cruz se erigiu, \nDela o dia fugiu, \nComo emblema de vergonha e dor; \nMas contemplo esta cruz, \nPorque nela Jesus \nDeu a vida por mim, pecador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim, eu amo a mensagem da cruz \nTé morrer eu a vou proclamar; \nLevarei eu também minha cruz \nTé por uma coroa trocar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desde a Glória dos céus, \nO Cordeiro de Deus, \nAo Calvário humilhante baixou; \nEssa cruz tem p\'ra mim \nAtrativos sem fim, \nPorque nela Jesus me salvou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nesta cruz padeceu \nE por mim já morreu, \nMeu Jesus, para dar-me o perdão; \nE eu me alegro na cruz, \nDela vem graça e luz, \nPara minha santificação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu aqui com Jesus, \nA vergonha da cruz \nQuero sempre levar e sofrer; \nCristo vem me buscar, \nE com Ele, no lar, \nUma parte da glória hei de ter.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/291-a-mensagem-da-cruz/simplificada.html',
      ),
      Hino(
        codigo: 107,
        titulo: 'CENÁRIO DE DOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero vos relembrar um cenário, \nDo nosso glorioso Deus forte; \nQue venceu o adversário, \nAté a própria morte.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Foi no alto daquela colina, \nOnde Jesus foi crucificado, \nPelos golpes, de mãos assassinas, \nConduziu o madeiro pesado. \nSeus algozes levaram martelos, \nCom os cravos, e, lanças também, \nComo para travar um duelo, \nMas, Jesus não brigou com ninguém.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Suspenso, entre o céu e a terra, \nJesus foi, por mim levantado. \nEstava travada uma guerra, \nDe extermínio a todo pecado.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/parada-firme-em-jesus/alto-da-colina/',
      ),
      Hino(
        codigo: 108,
        titulo: 'ELE SOFREU POR MIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu li que Jesus fora preso; \nDe dor a minh\'alma vibrou; \nEu antes assim não sentia, \nAgora isto a mim empolgou, \nEu li que Ele foi conduzido \nA corte de Jerusalém; \nAli padeceu grande afronta \nFoi c\'roado de espinhos também.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu sei que eu era culpado, \nMas Ele sofreu já por mim; \nEu sei que Ele era inocente, \nPadecendo tudo assim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu li que Jesus foi julgado; \nU\'a cruz mui pesada levou, \nE nela, por mim expirando, \nOs meus vis pecados tomou; \nEnquanto na cruz, pendurado, \nU\'a lança Seu lado furou; \nNa esponja Lhe deram vinagre, \nE Ele, por mim, o tragou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Depois José de Arimatéia \nE outros discípulos também \nPuseram-No, em um sepulcro, \nE os guardas vigiavam bem; \nEnquanto no mundo, Ele disse: \nQue havia de ressuscitar, \nE Deus fez então um milagre, \nFazendo-O dos mortos tornar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os guardas ainda vigiavam, \nQuando um anjo veio do Céu, \nE a pedra que estava na porta, \nCom grande poder removeu; \nDepressa os laços caíram; \nO plano de Deus era assim; \nE a luz e a vida resplendem, \nE isto foi tudo por mim!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/ricardo-marcelo/465-ele-sofreu-por-mim/',
      ),
      Hino(
        codigo: 109,
        titulo: 'JESUS NAZARENO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus Nazareno, pregado na cruz, \nCoberto de sangue seu rosto ficou. \nSeu rosto em declínio, qual anjo divino, \nCoroa de espinhos, o povo lhe deu.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            '“Eloí, Eloí! Lama Sabactani”! \nClamava ao Pai, o Divino Jesus. \nO bom Redentor, de novo clamou, \nSem forças, porém o Mestre expirou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não se maldizia da ingratidão \nQue o povo fizera, sem ter compaixão; \nVinagre lhe deram, Jesus recusou, \nSofrendo agonia da morte e da dor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A luz se fez trevas, a terra tremeu, \nMorrendo na cruz o Filho de Deus. \nRasgou-se o véu da separação, \nNos dando a graça, a paz e o perdão.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/gerson-rufino/jesus-nazareno/',
      ),
      Hino(
        codigo: 110,
        titulo: 'MADEIRO LAVRADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cortaram um madeiro, \nFizeram uma cruz para o meu Salvador \nMadeiro lavrado, \nCom pregos cravados pesado ficou \nEle carregou a cruz e no caminho caiu, \nMas, Deus deu-Ihe graça \nMorrendo na cruz por mim e por ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Foi feita assim a cruz, \nDo meu Salvador; \nMadeiro lavrado \nCom pregos cravados \nPesado ficou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Perante Pilatos \nJesus foi levado como um malfeitor \nChegando-se a ele, olhando ao Mestre \nAssim perguntou: “És o rei dos judeus”? \nDisse-lhe Jesus: “Na verdade eu sou”, \nO meu reino é eterno \nNão é deste mundo, daqui eu não sou”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chegando ao calvário, \nPregaram na cruz o meu salvador, \nCom a coroa de espinhos \nSua fronte sangrando, ao Pai suplicou \nTraspassado de dor ficou o meu salvador \nAs três horas da tarde, inclinou a cabeça \nE, ali expirou!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/madeiro-lavrado/',
      ),
      Hino(
        codigo: 111,
        titulo: 'BREVE NOTÍCIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muito em breve vai sair uma noticia; \nQue um povo desapareceu! \nEra um povo muito humilde \nQue, aqui muito sofreu, \nEste povo era o povo de Deus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Onde está aquele povo barulhento? \nOnde está que não se vê nenhum irmão? \nAlguém com voz de lamento, \nVai dizer, neste momento, \nAquele povo foi-se embora pra Sião.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onde está o dirigente desta igreja? \nE os obreiros daqui onde estão? \nAs mensagens que pregavam, \nMuitos tristes se alegravam \nEles também, foram embora pra Sião.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onde está a juventude desta igreja? \nE as irmãs do circulo de oração? \nQue a Deus sempre oravam, \nE, as crianças que cantavam? \nElas também, foram embora pra Sião.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Depois deste grande acontecimento, \nMuitos crentes desviados vão voltar, \nProcurando os irmãos \nPara reconciliar \nMas, infelizmente, não vão encontrar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/shirley-carvalhaes/desapareceu-um-povo/',
      ),
      Hino(
        codigo: 112,
        titulo: 'PRENDERAM CRISTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Prenderam Cristo e ele a cruz carregou; \nPorque tomou a cruz. \nPara o calvário se encaminhou; \nPorque tomou a cruz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Porque tomou a cruz? \nO Senhor sobre si \nPorque tomou Cristo a cruz de terror? \nFoi por mim e por ti',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cravos furaram as mãos e os pés; \nPor que tomou a cruz? \nTodos zombaram com fúria e altivez; \nPor que tomou a cruz?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo sofreu agonia cruel; \nPor que tomou a cruz. \nDesamparado expirou, sim, fiel; \nPor que tomou a cruz?',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/feliciano-amaral/por-que-tomou-a-cruz/',
      ),
      Hino(
        codigo: 113,
        titulo: 'SE ISTO NÃO FOR AMOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deixou o esplendor de sua glória \nSabendo o destino aqui, \nEstava só e ferido no gólgota \nPara dar sua vida por mim!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Se isto não for amor, o oceano secou, \nNão há estrelas no céu \nE as andorinhas não voam mais \nSe isto não for amor, o céu não é real, \nTudo perde o valor, se isto não for amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mesmo na morte lembrou-se \nDo ladrão que a seu lado estava \nCom amor e ternura falou-lhe \nAo paraíso comigo irás.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/ruthe-dayanne/se-isso-nao-for-amor/',
      ),
      Hino(
        codigo: 114,
        titulo: 'PODER DO SANGUE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O teu pecado tu queres deixar? \nNo Sangue há poder, sim, há poder; \nQueres do mal a vitória ganhar? \nSeu Sangue tem este poder!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Há poder, sim, força e vigor \nNeste Sangue de Jesus; \nHa poder, sim, no bom Salvador, \nOh! Confia no Cristo da Cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres os vícios abandonar? \nNo Sangue há poder, sim, há poder; \nConfia em Cristo para te curar, \nSeu Sangue tem este poder!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Paralítico, queres andar? \nNo Sangue há poder, sim, há poder; \nPara fazer-te também caminhar, \nSeu Sangue tem este poder!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres pureza p\'ra teu coração? \nNo Sangue há poder, sim, há poder; \nMais lealdade, mais consagração, \nSeu Sangue tem este poder!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres de Cristo a mensagem levar? \nNo Sangue há poder, sim, há poder; \nQueres co\'os anjos, na glória cantar? \nSeu Sangue tem este poder!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 115,
        titulo: 'MEU REDENTOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na cruz morrendo meu Redentor; \nMinhas maldades todas levou \nSe O recebes, tens Seu amor, \nPois teus pecados, Jesus perdoou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quando Deus, o Sangue vir, \nQue Jesus já verteu, \nPassará sem te ferir, \nNo Egito assim sucedeu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus quer salvar ao vil malfeitor, \nComo promete, sempre fará; \nNEle confia, ó pecador, \nE pela fé nova vida terás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Breve se finda a tua luz, \nE no juízo tu vais entrar; \nNão te detenhas, vem a Jesus, \nQue teus pecados deseja apagar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que maravilha, que grande amor! \nSe hoje creres, salvo serás! \nCristo te chama, vem pecador, \nE gozo eterno no Céu fruirás.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/meu-redentor/',
      ),
      Hino(
        codigo: 116,
        titulo: 'MEU JESUS! MEU JESUS!',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De meu terno Salvador, \nCantarei o imenso amor, \nDando glória e louvor a Jesus, \nPois das trevas me chamou, \nDe cadeias me livrou, \nE da morte me salvou meu Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Meu Jesus! Meu Jesus! \nQue precioso é o nome de Jesus! \nCom Seu sangue me limpou; \nDe Seu gozo me fartou; \nOh! que graça me mandou, meu Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que triste condição \nA do ímpio coração; \nMe salvou da perdição, meu Jesus; \nDo pecado, o perdão; \nDa ruína, a salvação; \nPor tristeza, galardão, meu Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo mundo a vagar, \nSolitário sem parar, \nSem a doce paz gozar de Jesus; \nTodo pranto a sofrer \nHão passados, e prazer \nJá começo a receber de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que sangue remidor \nEncontrei no Salvador, \nSangue purificador, de Jesus! \nDai louvores em ação \nDa bendita salvação! \nHinos dai por gratidão a Jesus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/meu-jesus-meu-jesus/',
      ),
      Hino(
        codigo: 117,
        titulo: 'O PRECIOSO SANGUE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nMeu Senhor verteu, \nQuando, para resgatar-nos, \nPadeceu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nSangue de Jesus, \nQue por nós, foi derramado \nSobre a cruz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nSangue remidor! \nSim, com este nos remiste, \nRedentor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nSangue expiador! \nEis o que da pena livra \nO malfeitor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nPurificador! \nQue de toda a mancha lava \nO pecador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nFala-nos de paz; \nTudo quanto a lei exige, \nSatisfaz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nPor Ele entrarei \nSem receio, na presença \nDo meu Rei!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que precioso sangue, \nDo bom Salvador! \nHoje, a todos manifesta \nSeu amor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/leandro-izauto/29-o-precioso-sangue/',
      ),
      Hino(
        codigo: 118,
        titulo: 'PELO SANGUE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo mundo brilha a luz, \nDesde que morreu Jesus, \nPendurado lá na cruz do Calvário! \nOs pecados carregou \nE de culpa nos livrou, \nCom o Sangue que manou, no Calvário!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Pelo Sangue, pelo Sangue, \nSomos redimidos, sim \nPelo Sangue carmesim; \nPelo Sangue, pelo Sangue, \nPelo Sangue de Jesus, no Calvário!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Antes, tinha mui temor, \nMas, agora, tenho amor, \nPois compreendo o valor do Calvário; \nEu vivi na perdição \nMas achei a salvação \nPela grande redenção: o Calvário!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'És um grande pecador? \nEis aqui teu Salvador! \nTema do bom pregador: o Calvário, \nO Cordeiro divinal \nPadeceu na cruz teu mal, \nE oferece graça tal, no Calvário.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/192-pelo-sangue/simplificada.html',
      ),
      Hino(
        codigo: 119,
        titulo: 'QUAL O PREÇO DO PERDÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Qual o preço do perdão? \nSó o sangue de Jesus Cristo. \nO que limpa o coração? \nSó o sangue de Jesus Cristo.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Qual o poder real \nQue limpa todo o mal, \nE dá paz divinal? \nSó o sangue de Jesus Cristo.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fez resgate eficaz \nSó o sangue de Jesus Cristo. \nDeu-nos santidade e paz. \nSó o sangue de Jesus Cristo.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sempre pode me curar, \nSó o sangue de Jesus Cristo. \nE do mal me libertar. \nSó! o sangue de Jesus Cristo.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá no Céu, eu vou cantar: \nSó o sangue de Jesus Cristo, \nDeu-me graça para entrar. \nSó o sangue de Jesus Cristo.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/qual-preco-do-perdao-/simplificada.html',
      ),
      Hino(
        codigo: 120,
        titulo: 'SALVO ESTÁS LIMPO ESTÁS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tens achado em Cristo plena salvação, \nPelo sangue vertido na cruz? \nToda mancha lava de teu coração, \nEste sangue eficaz de Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Salvo estás, limpo estás, \nPelo sangue de Cristo Jesus? \nTens teu coração mais alvo que a luz, \nFoste limpo no sangue eficaz?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vives sempre ao lado do teu Salvador, \nPelo sangue que mana da cruz? \nDo pecado foste sempre vencedor, \nComo foi teu bendito Jesus?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Terás roupa branca quando vier Jesus, \nFoste limpo na fonte do amor? \nEstás pronto p\'ra seguir ao Céu de luz, \nPelo sangue purificador?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo hoje dá pureza e mui poder; \nFita os olhos na cruz do Senhor, \nDela, fonte sai que te enche de prazer, \nQue te farta de vida e vigor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/salvo-estas-limpo-estas/',
      ),
      Hino(
        codigo: 121,
        titulo: 'SOB O TEU SANGUE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Asperge hoje meu coração, \nCom sangue Teu, ó Redentor! \nLiberta-me da vil tentação, \nCom sangue Teu, Senhor!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sob o sangue Teu, Senhor, \nGuarda-me da corrupção! \nSob o sangue expiador, \nEu tenho proteção!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De todas dúvidas, do temor, \nNo sangue Teu, vem me lavar, \nDos males do grande tentador, \nÓ queiras me livrar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Refúgio acha o pecador, \nNo sangue Teu, ó meu Jesus; \nAsperge-me sempre, ó Senhor, \nNo sangue, lá na cruz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó vem me enchendo do Teu vigor, \nPelo manar do sangue Teu; \nFazendo-me mais que vencedor, \nPelo poder de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Concede-me a perfeita paz, \nPor Tua cruz e sangue Teu; \nCom ricos dons, ó me satisfaz, \nE faz-me ver o Céu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/sob-sangue-teu/iurd.html',
      ),
      Hino(
        codigo: 122,
        titulo: 'ETERNA ROCHA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Rocha eterna, meu Jesus, \nQue, por mim, na amarga cruz, \nFoste morto em meu lugar, \nMorto para me salvar; \nEm Ti quero me esconder, \nSó Tu podes me valer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minhas obras, eu bem sei, \nNada valem ante a lei; \nSe eu chorasse sem cessar, \nTrabalhasse sem cansar, \nTudo inútil, tudo em vão! \nSó em Ti há salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nada trago a ti, Senhor! \n‘Spero só em Teu amor! \nTodo indigno e imundo sou, \nEis, sem Ti, perdido estou! \nNo Teu sangue, ó Salvador, \nLava um pobre pecador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a morte me chamar, \nE ante Ti me apresentar, \nRocha eterna, meu Jesus, \nQue por mim, na amarga cruz, \nFoste morto em meu lugar, \nQuero em Ti só me abrigar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 123,
        titulo: 'ESCRAVA RESGATADA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis a escrava resgatada, \nGrande preço Cristo deu, \nNão foi ouro, nem foi prata, \nFoi seu sangue que verteu.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'De maneira tal amaste, \nQue por mim, Senhor, morreste; \nPra remir-me do pecado \nTu sofreste em meu lugar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois agora que sou tua, \nSem jamais a Ti perder, \nQuero, meu Senhor, servir-Te, \nGrata, e só por Ti viver.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero receber teu jugo; \nEm teus passos caminhar; \nSó a Ti eu me subjugo, \nVou contigo em paz morar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis que estou aqui na terra, \nEsperando o teu voltar; \nLevarás então a escrava \nQue no céu vai habitar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/escrava-resgatada/',
      ),
      Hino(
        codigo: 124,
        titulo: 'ROCHA ETERNA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Rocha eterna, foi na cruz \nQue morreste Tu, Jesus; \nVem de Ti um sangue tal \nQue me limpa todo mal; \nTraz as bênçãos do perdão: \nGozo, paz e salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nem trabalho, nem penar \nPode o pecador salvar; \nSó Tu podes, bom Jesus, \nDar-me vida, paz e luz. \nPeço-Te perdão, Senhor, \nPois confio em teu amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis que vem a morte atrás \nDesta vida tão fugaz; \nQuando eu ao meu lar subir, \nE teu rosto em glória vir, \nRocha eterna, que prazer \nEu terei se em Ti viver!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/rocha-eterna/',
      ),
      Hino(
        codigo: 125,
        titulo: 'SUBSTITUIÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Morri na cruz por ti, \nMorri pra te livrar; \nMeu sangue, sim, verti, \nE posso te salvar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'Morri, morri na cruz por ti; \nQue fazes tu por Mim?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aqui vivi por ti, \nCom muito dissabor; \nSim, tudo fiz aqui, \nPra ser teu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sofri na cruz por ti, \nA fim de te salvar; \nA vida conseguir, \nQue tu irás gozar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu trouxe salvação, \nDos altos céus, favor; \nÉ livre meu perdão; \nSincero, meu amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/092-substituicao/',
      ),
      Hino(
        codigo: 126,
        titulo: 'RESSUSCITOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Da sepultura, para o céu, Jesus voltou, \nDepois que o pecado aniquilou; \nCom gran poder foi que ressuscitou, \nE liberdade aos presos proclamou; \nTremendo, a terra O saudou, \nPois que da morte se levantou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ressuscitou! Ressuscitou! \nE para o céu Jesus tornou; \nMas voltará, também de lá, \nE neste mundo, então reinará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em riso, o pranto dos discípulos se tornou, \nPois vivo, Cristo se apresentou; \n- “Parti p\'ra Galiléia", ordenou,\nE a promessa santa revelou:\n“Poder do alto, eu vos dou\nPois ao meu Pai, pedi-lo vou”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus a Sua mão divina levantou,\nAbençoando seres que salvou,\nE, triunfante, para o céu tornou,\nE uma nuvem logo O ocultou;\nMas a promessa lhes deixou:\n"Eis que convosco p\'ra sempre estou”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sentado à destra de Deus Pai, Jesus está, \nPor sua Esposa suplicando já; \nO mundo disto não cogita cá, \nPorque não vê a luz que brilha lá; \nMui breve, Cristo voltará, \nMas só os Seus, ao céu levará.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/ressucitou/',
      ),
      Hino(
        codigo: 127,
        titulo: 'RESSURREIÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis, morto, o Salvador \nNa sepultura! \nMas, com poder, vigor, \nRessuscitou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Da sepultura, saiu! \nCom triunfo e glória ressurgiu! \nRessurgiu, vencendo a morte e o seu poder; \nPode agora a todos vida conceder! \nRessurgiu! Ressurgiu! \nAleluia! Ressurgiu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tomaram precaução \nCom seu sepulcro; \nMas tudo foi em vão \nPara O reter.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A morte conquistou \nCom grande glória! \nOh! Graças! alcançou \nVida eternal.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/099-ressurreicao/',
      ),
      Hino(
        codigo: 128,
        titulo: 'RESSURGIU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo já ressuscitou; aleluia! \nSobre a morte triunfou; aleluia! \nTudo consumado está; aleluia! \nSalvação de graça dá; aleluia!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Uma vez na cruz sofreu; aleluia! \nUma vez por nós morreu; aleluia! \nMas agora vivo está; aleluia! \nE pra sempre reinará; aleluia!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Gratos hinos entoai; aleluia! \nA Jesus, o Grande Rei; aleluia! \nPois à morte quis baixar; aleluia! \nPecadores pra salvar; aleluia!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/101-ressurgiu-cristo-ja-ressuscitou/',
      ),
      Hino(
        codigo: 129,
        titulo: 'A VOZ DE JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que doce voz tem meu Senhor, \nVoz de amor, tão terna e graciosa, \nQue enche o coração, dá consolação \nQue só o crente goza.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Qual maior prazer que Lhe ouvir dizer: \n“Vem, meu filho, vem escutar \nO que Eu fiz por ti, tudo o que sofri \nNa cruz pra te resgatar”?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chamou-me não só uma vez \nTantas té que eu, triste, humilhado, \nPude a voz ouvir, pude então sair \nDas garras do pecado,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus não me deixa sofrer, \nSua voz me ensina o caminho \nDe vencer o mal, com firmeza tal \nQue nunca estou sozinho.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/a-voz-de-jesus/',
      ),
      Hino(
        codigo: 130,
        titulo: 'CRISTO É PEDRA FINA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo é pedra fina,\nPedra de esquina, pedra angular\nCristo é rocha pura,\nToda criatura pode segurar!\nEsta Rocha é Cristo,\nTodo imprevisto, pode resolver!\nTodos teus pecados serão perdoados\nCristo tem poder.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo tem poder.\nE sabe lutar!\nEle é poderoso, Ele é o leão                      (Bis)\nDa tribo de Judá',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Esta Rocha é água\nE quem tem suas mágoas, Ela vai tirar,\nNunca estou sozinho, Cristo é meu caminho,\nNele tenho paz.\nTem paz verdadeira, quem nesta Rocha\nFirmado está,\nCristo é a verdade;\nE se creres Nele, te libertarás.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/trio-alexandre/cristo-tem-poder/',
      ),
      Hino(
        codigo: 131,
        titulo: 'CONTA PRA JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se desanimares com a tua cruz,\nLembra que maior levou o teu Jesus,\nNão te desanimes com a tua cruz,\nO que tu precisas conta pra Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Conta pra Jesus, onde é a tua dor,\nEle te ajuda a carregar a cruz,\nCom insistência ora, que tu vais vencer,\nO que tu precisas conta pra Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se o inimigo te desanimar,\nDizendo não podes a Jesus seguir;\nTu não dês ouvido, ora ao teu Senhor\nE o que tu precisas, conta pra Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se em língua estranha ainda não falar\nCom Deus em mistérios podes conversar.\nE o Santo Espírito inundará o teu ser\nE o que tu precisas conta pra Jesus.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 132,
        titulo: 'CRER E OBSERVAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus confiar, sua lei observar, \nOh, que gozo, que bênção, que paz! \nSatisfeitos guardar tudo quanto ordenar \nAlegria perene nos traz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Crer e observar \nTudo quanto ordenar; \nO fiel obedece \nAo que Cristo mandar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O inimigo falaz e a calúnia mordaz \nCristo pode desprestigiar; \nNem tristeza, nem dor, nem a intriga maior \nPoderão ao fiel abalar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que delicia de amor, comunhão com o Senhor \nTem o crente zeloso e leal; \nO seu rosto mirar, seus segredos privar, \nSeu consolo constante e real.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Resoluto, Senhor, e com fé, zelo e ardor, \nOs teus passos queremos seguir; \nTeus preceitos guardar, o teu nome exaltar, \nSempre a tua vontade cumprir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/crer-observar/',
      ),
      Hino(
        codigo: 133,
        titulo: 'COM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Triste e sombrio foi meu viver, \nLonge de ti, meu Salvador; \nPaz e perdão de ti venho obter, \nJunto de ti, Senhor. \nFoi grande a luta da provação, \nTenho sofrido muita aflição; \nPra confortar o meu coração, \nEu venho a ti, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minhas vaidades atirarei \nLonge de mim, ó Salvador; \nPois teu querer será minha lei, \nServir-te-ei, Senhor. \nO teu amor desejo provar, \nA tua graça quero gozar. \nSempre contigo almejo ficar, \nTeu sempre quero ser.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Medo da morte nunca terei; \nPerto de mim tu sempre estás, \nPois ao teu lar decerto eu irei, \nTu me receberás. \nJunto de ti, pois, quero viver, \nJunto de ti eu vou combater, \nJunto de ti vencer ou morrer, \nCristo, meu Salvador.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 134,
        titulo: 'ERAM CEM OVELHAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eram cem ovelhas juntas no aprisco.\nEram cem ovelhas que amante, cuidou.\nPorém, numa tarde ao contá-las todas,\nLhe faltava uma, lhe faltava uma,\nE triste chorou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'As noventa e nove deixou no aprisco\nE pelas montanhas a buscá-la foi;\nA encontrou gemendo, tremendo de frio;\nCurou suas feridas, colocou-a em seus ombros\nE ao redil voltou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Essa mesma história torna a repetir-se,\nPois muitas ovelhas perdidas estão.\nMas ainda hoje o pastor amado\nCura tuas feridas, cura tuas feridas\nE te dá perdão.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/cem-ovelhas/',
      ),
      Hino(
        codigo: 135,
        titulo: 'CRISTO PRA MIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que descanso em Jesus encontrei! \nCristo p\'ra mim! Cristo p\'ra mim! \nOh! que tesouros infindos achei! \nCristo p\'ra mim! Cristo p\'ra mim! \n\‘Scolham os outros o mundo p\'ra si: \nBusquem riquezas, delicias aqui; \nEu \'scolherei, ó Jesus, sempre a Ti! \nCristo p\'ra mim! Cristo p\'ra mim! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quer na aflição, na doença ou na dor; \nCristo p\'ra mim! Cristo p\’ra mim! \nQuer na saúde, na força ou vigor; \nCristo p\'ra mim! Cristo p\'ra mim! \nSempre ao meu lado p\'ra me socorrer, \nCom Seu amor, sim, e com Seu poder; \nEm cada transe pronto a me valer; \nCristo p\'ra mim! Cristo p\'ra mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No dia amargo da perseguição: \nCristo p\'ra mim! Cristo p\'ra mim! \nNas duras provas e na tentação; \nCristo p\'ra mim! Cristo p\'ra mim! \nEle, o pecado e o mundo venceu \nQuando, por mim, no Calvário morreu; \nE da vitória a certeza me deu; \nCristo p\'ra mim! Cristo p\'ra mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando no vale da morte eu entrar, \nCristo p\'ra mim! Cristo p\'ra mim! \nQuando perante meu Deus m\'encontrar; \nCristo p\'ra mim! Cristo p\'ra mim! \nSó no Teu sangue confio, Senhor, \nSó no Teu sempre imutável amor! \nInda outra vez cantarei, Salvador: \nCristo p\'ra mim! Cristo p\'ra mim ',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/cristo-pra-mim/',
      ),
      Hino(
        codigo: 136,
        titulo: 'DEUS TOMARÁ CONTA DE TI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em todo o tempo, irmão, o Senhor \nTomará conta de ti. \nCristo, que fala de vida e amor, \nTomará conta de ti ',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deus tomará conta de ti, \nDeus tomará conta de ti, \nNEle descansa, sempre aqui, \nPois tem cuidado Deus, de ti,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em toda prova, irmão, o Senhor \nTomará conta de ti. \nCristo, que é teu amado Pastor \nTomará conta de ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em toda parte, irmão, o Senhor \nTomará conta de ti. \nCristo, que nos dá poder e valor, \nTomará conta de ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chegando a morte, irmão, o Senhor \nTomará conta de ti. \nCristo será teu fiel condutor; \nTomará conta de ti.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/061-deus-tomara-conta-de-ti/',
      ),
      Hino(
        codigo: 137,
        titulo: 'DOIS DISCÍPULOS NO CAMINHO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dois discípulos no caminho de Emaús \nIam falando a respeito de Jesus, \nUm viajante deles se aproximou, \nNão perceberam que era o meigo Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Fica conosco, nosso amado Salvador. \nFica conosco pelo teu imenso amor. \nComo os discípulos Te pediram \nNuma aldeia de Emaús, \nFica conosco, nosso amado e bom Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eles falavam a respeito de Jesus, \nVarão profeta que foi poderoso em obras, \nDiante de Deus e todo o povo. Aleluia! \nEsse Jesus que ainda hoje nos conduz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Estando à mesa tomou o pão e o abençoou, \nE ao partir eles O reconheceram, \nCheios de gozo em ver o Filho de Deus. \nNo mesmo instante Ele desapareceu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/joel-jonas/caminho-de-emaus/',
      ),
      Hino(
        codigo: 138,
        titulo: 'EM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus, vivendo cada dia, \nEm Jesus eu tenho alegria! \nEm Jesus oh, doce harmonia! \nEm Jesus, desfruto a paz de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus, na Rocha inabalável, \nEm Jesus, no Homem incomparável! \nEm Jesus, no Deus tão adorável! \nEm Jesus, o mal não temerei!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus, a graça é infinita, \nEm Jesus, oh! bênção inaudita; \nEm Jesus, minh\'alma é bendita; \nEm Jesus eu tenho salvação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus não temo o mal e a morte, \nEm Jesus estou firmado e forte! \nEm Jesus meu barco rumo ao norte; \nEm Jesus eu sempre hei de vencer!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/em-jesus/simplificada.html',
      ),
      Hino(
        codigo: 139,
        titulo: 'FALA, JESUS QUERIDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fala, Jesus querido; fala-me, hoje sim!\nFala com Tua bondade; à minha vida sim;\nMeu coração aberto \'stá p\'ra Tua voz ouvir;\nEnche-me de louvores e gozo p\'ra Te servir.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Fala-me suavemente! Fala, com muito amor!\nVencedor para sempre, livre te hei de por,\nFala-me cada dia, sempre em terno tom;\nOuvir Tua voz eu quero e neste mesmo som.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para teus filhos fala, e, no caminho bom,\nPela bondade os guia a pedir o santo dom;\nQuererão consagrar-se para suas vidas dar.\nObedecendo a Cristo e com fervor O amar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como no tempo antigo, Tu revelaste a lei,\nMostra-me Tua vontade, e à Tua santa grei;\nDeixa-me gloriar-Te, quero a Ti louvar,\nCantar alegremente e sempre Te honrar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/151-fala-jesus-querido/',
      ),
      Hino(
        codigo: 140,
        titulo: 'FIRMEZA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em nada ponho a minha fé, \nSenão na graça de Jesus; \nNo sacrifício remidor, \nNo sangue do bom Redentor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A minha fé e o meu amor \nEstão firmados no Senhor. \nEstão firmados no Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se Lhe não posso a face ver, \nNa sua graça vou viver; \nEm cada transe, sem falhar, \nSempre hei de nEle confiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seu juramento é mui real, \nAbriga-me no temporal; \nAo vir cercar-me a tentação, \nÉ Cristo a minha salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Assim que o seu clarim soar, \nIrei com Ele me encontrar; \nE gozarei da redenção \nCom todos que no céu estão.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/366-firmeza/',
      ),
      Hino(
        codigo: 141,
        titulo: 'JESUS, O BOM AMIGO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Achei um bom Amigo, \nJesus, o Salvador, \nO Escolhido dos milhares para mim; \nDos vales é o Lírio: é o forte Mediador, \nQue me purifica e guarda para Si, \nConsolador amado, meu Protetor do mal, \nSolicitude minha toma a Si.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Dos Vales é o Lírio, a Estrela da Manhã, \nO Escolhido dos milhares para mim. \nConsolador amado, meu Protetor do mal, \nSolicitude minha toma a Si, \nDos Vales é o Lírio a Estrela da Manhã, \nO Escolhido dos milhares para mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Levou-me as dores todas, \nAs mágoas lhe entreguei, \nMinha fortaleza é, na tentação. \nDeixei, por Ele tudo; os ídolos queimei; \nEle me conserva santo o coração \nQue o mundo me abandone; persiga o tentador; \nJesus me guarda até da vida o fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não desampara nunca, \nNem me abandonará, \nSe fiel e obediente eu viver; \nUm muro é de fogo, que me protegerá, \nTé que venha a mim o tempo de morrer, \nAo Céu então voando, sua glória eu verei \nOnde a dor e a morte jamais temerei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/jesus-bom-amigo-198/',
      ),
      Hino(
        codigo: 142,
        titulo: 'JESUS, O BOM PASTOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, o bom Pastor \nSeguiu-me com grande amor, \nE do abismo me livrou. \nEle estendeu-me a mão. \nGuiou-me na escuridão, \nÀ luz do seu divino amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Querido Salvador, o teu imenso amor \nEnche meu coração de gratidão; \nEu só não posso andar, vem-me, Senhor, guiar \nCom tua santa mão, à celestial mansão',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Estando com Jesus, \nCercado por sua luz, \nO mundo perde a atração. \nJamais vou me importar \nSe o mundo me desprezar, \nPois Cristo é todo o meu prazer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sei que no santo lar \nPra sempre vou descansar; \nE com Jesus lá estarei; \nQual digno vencedor, \nAos pés do meu Salvador \nPrazer infindo gozarei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/izaias-mendes/jesus-o-bom-pastor/',
      ),
      Hino(
        codigo: 143,
        titulo: 'MUI TRISTE EU ANDAVA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mui triste eu andava, sem gozo, e sem paz,\nMas eu hoje tenho alegria eficaz,\nE constantemente bendigo ao meu Deus,\nE é claro o motivo, pois sou de Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu sou de Jesus, Aleluia!\nDe Cristo Jesus, Meu Senhor!\nNão quero falhar, mas quero falar,\nAndar e viver com Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó! alma turbada! Por que lamentar?\nEm Cristo tu achas tesouros sem par.\nInfinda alegria, poder, salvação;\nOh! vem hoje a Cristo, sem hesitação!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/221-mui-triste-eu-andava/',
      ),
      Hino(
        codigo: 144,
        titulo: 'MEU SENHOR, SOU TEU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu Senhor, sou Teu, tua voz ouvi\nAo chamar-me com amor;\nMas de ti mais perto eu quero estar,\nÓ bendito Salvador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Mais perto da tua cruz\nQuero estar, ó Salvador!\nMais perto da tua cruz\nLeva-me, ó meu Senhor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A seguir-Te só, me consagro eu,\nConstrangido pelo amor;\nE alegre já me declaro teu,\nPra servir-te a Ti, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que pura e santa delicia é\nAos teus santos pés me achar,\nE com viva e reverente fé,\nCom meu Salvador falar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/325-mais-perto-da-tua-cruz/',
      ),
      Hino(
        codigo: 145,
        titulo: 'NÃO TEMAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Não temas! Contigo, eu sempre estarei!\n"Oh! rica promessa do bondoso Rei;\nQual estrela que brilha, lá na escuridão,\nEsta linda promessa brilha no meu coração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Comigo estar! Comigo estar! \nSim, Jesus me promete, \nSempre comigo estar. \nComigo estar! Comigo estar! \nSim, Jesus me promete, \nSempre comigo estar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os Lírios mais alvos, ei-los murchos estão! \nOs dias mais belos, quão depressa vão! \nCristo, o Lírio dos vales, nunca mudará; \nCristo, a luz celeste, sempre comigo estará!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E, se pelas águas tiver de passar, \nSeus braços eternos hão de me guardar; \nSim, mesmo no fogo, que vem me provar, \nMeu Senhor me promete sempre comigo estar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/nao-temas/original.html',
      ),
      Hino(
        codigo: 146,
        titulo: 'NÃO SOU MEU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não sou meu! Por Cristo salvo, \nQue por mim morreu na cruz, \nEu confesso alegremente, \nQue pertenço ao bom Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não sou meu! Oh! Não sou meu! \nBom Jesus, sou todo Teu! \nHoje mesmo e para sempre, \nBom Jesus, sou todo Teu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não sou meu! Por Ele remido, \nQuando o sangue derramou; \nNa Sua graça confiando, \nQue minh\'alma resgatou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jamais meu! Ó santifica \nTudo quanto sou, Senhor! \nDa vaidade e da soberba, \nVem livrar-me, Salvador.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/nao-sou-meu/',
      ),
      Hino(
        codigo: 147,
        titulo: 'NÃO POSSO EXPLICAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mais perto de Jesus, procuro sempre eu chegar,\nMais belo que o ouro do sol nado é a Ti mirar.\nEm pensamento, sonhos, tanta glória nunca vi;\nPois Ele é mais belo do que eu jamais previ!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não posso explicar\nQuão meigo é Jesus;\nMas, face a face, no Teu lar,\nEu Te verei, Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Estrela resplendente da manhã é minha luz;\nO Lírio dos vales é o bom Senhor Jesus;\nSuave e doce é o cheiro que só vem de ti;\nPois Ele é mais belo do que eu jamais previ!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se mágoas vêm me perturbar, o bálsamo Ele tem;\nMe toma nos Seus braços e, assim, descanso bem;\nNa cruz levou Jesus o meu pecado sobre Si;\nPois Ele é mais belo do que eu jamais previ!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/83-nao-posso-explicar/',
      ),
      Hino(
        codigo: 148,
        titulo: 'OH! JESUS ME AMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Longe do Senhor, andava,\nNo caminho de horror,\nPor Jesus não perguntava,\nNem queria o Seu amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! por que Jesus me ama?\nEu não posso t’explicar!\nMas, a ti também te chama,\nPois deseja te salvar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No juízo não pensava,\nNem na minha perdição,\nNem minh\'alma desejava\nA eterna salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já cansado do pecado\nFui aos pés do Salvador,\nE ali, caiu o fardo\nDe tristeza e de dor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como é maravilhoso,\nPertencer ao meu Jesus!\nTer a graça, o repouso,\nE ficar ao pé da cruz!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/169-oh-jesus-me-ama/',
      ),
      Hino(
        codigo: 149,
        titulo: 'ONDE QUER QUE SEJA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onde quer que seja, com Jesus irei; \nEle é meu bendito Salvador e Rei. \nSeja para a guerra, para batalhar, \nSeja pra campina para semear.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Onde quer, onde quer que Deus me mandar, \nPerto do meu Salvador eu quero andar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onde quer que seja, seguirei Jesus, \nDiz o coração que vive em sua luz; \nPerto dÊle sempre eu seguro vou, \nOnde quer que seja, pois, contente estou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seja, pois, pra onde quer que me levar, \nAcharei com Ele ali meu doce lar. \nOnde quer que seja, sempre cantarei: \n“Tu, Senhor, comigo estás, não temerei.”',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 150,
        titulo: 'OH! MEU JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh, meu Jesus, quando lutas no caminho encontrar \nA Tua mão divina vem me ajudar; \nNão temerei amparado por Ti mesmo, meu Jesus, \nÓ Salvador, a vitória me vem por Tua luz, \nPor Ti espero somente, meu Senhor, \nPara andar de valor em valor; \nÓ meu Jesus, minhas forças hei de ver mais aumentar \nTendo a fé; Tua graça me há de bastar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó meu Jesus, encostado em Teu braço vou andar, \nE com amor na sã Palavra meditar; \nSempre assim na peleja, por Jesus eu vencerei, \nE pela fé, abrigado do mal estarei; \nJá bem armado as trevas desfarei, \nPelo poder de Jesus, o meu Rei! \nO meu Jesus, que me dás, no coração, do Teu amor, \nHei de Ti ver glorioso, no Céu d\'esplendor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó meu Jesus, o Teu nome invocarei com mui amor, \nTodo o poder Te foi entregue Salvador; \nDe todo o ser, meu joelho, a Ti se dobrará; \nQue és o Senhor toda língua testiticará, \nOs nossos pés, Salvador, queiras firmar \nNa Rocha, que não se pode abalar; \nÓ meu Jesus, Tua graça quero sempre procurar, \nTé que eu vá nos Teus braços enfim repousar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 151,
        titulo: 'O PILOTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Guia, Cristo, minha nau \nSobre o revoltoso mar; \nTão enfurecido e mau, \nQuer fazê-la naufragar. \nVem, Jesus, oh! vem guiar, \nMinha nau vem pilotar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como sabe serenar \nBoa mãe o filho seu, \nVem, acalma, assim, o mar \nQue se eleva até ao céu. \nVem, Jesus, oh! vem guiar, \nMinha nau vem pilotar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se no porto quando entrar, \nMais o mar se enfurecer, \nQue me possa deleitar \nEm ouvir Jesus dizer: \nEntra, pobre viajor, \nNo descanso do Senhor',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 152,
        titulo: 'O AMOR INESGOTÁVEL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Santo amor de Cristo, que não terá igual, \nA Sua vera graça, sublime e eternal, \nE a misericórdia imensa como o mar, \nA qual ao Céu atinge, com gozo, hei de cantar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Como é inesgotável! \nO amor de meu Jesus! \nRico e inefável; nada é comparável \nAo amor de meu Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus andou no mundo, e o povo O procurou \nE todas as angústias, sim, aos Seus pés deixou; \nE Seu amor brotava, qual rio divinal, \nPujante, forte, imenso, sanando todo o mal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Também, nos olhos cegos pôs uma nova luz, \nA luz que nos dá vida, que já brilhou na cruz; \nE deu também às almas, a glória de Seu ser, \nAo implantar Sua graça, e Seu real poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O amor de Jesus Cristo, no mundo, é um fanal,\nQue marca vitorioso a senda do ideal\nEmbora passem os anos, é sempre eficaz,\nPrecioso é dar à alma incomparável paz.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 153,
        titulo: 'O BONDOSO AMIGO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quão bondoso amigo é Cristo! \nCarregou co\'a nossa dor, \nE nos manda que levemos \nOs cuidados ao Senhor. \nFalta ao coração dorido \nGozo, paz, consolação? \nIsso é porque não levamos \nTudo a Deus em oração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu estás fraco e carregado \nDe cuidados e temor? \nA Jesus, refúgio eterno, \nVai com fé teu mal expor! \nTeus amigos te desprezam? \nConta-Lhe isso em oração, \nE com Seu amor tão terno, \nPaz terá no coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo é verdadeiro amigo, \nDisto provas nos mostrou, \nQuando p\'ra levar consigo \nO culpado encarnou. \nDerramou Seu sangue puro \nNossa mancha p\'ra lavar; \nGozo em vida e no futuro. \nNEle podemos alcançar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/200-bondoso-amigo/',
      ),
      Hino(
        codigo: 154,
        titulo: 'PELO VALE ESCURO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo vale escuro seguirei Jesus, \nMas por ti seguro, vendo a tua luz. \nO meu passo incerto tu dirigirás; \nAo sentir-Te perto, nunca perco a paz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Breve a noite desce, noite de Emaús, \nE meu ser carece de Te ver, Jesus; \nCompanheiro amigo, ao meu lado vem! \nFica, ó Deus, comigo, infinito bem!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os espinhos tantos que nos vêm sangrar, \nSão remédios santos para nos curar; \nOnde existe a graça do bondoso Deus, \nTudo o que se passa nos conduz aos Céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não há dor que seja sem divino fim; \nFaze, ó Deus, que a igreja compreenda assim, \nE, apesar das trevas, possa ver, Senhor, \nQue Tu mesmo a levas com imenso amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/272-seguranca-e-paz/',
      ),
      Hino(
        codigo: 155,
        titulo: 'PENSANDO EM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nas horas que passo pensando em Jesus \nAs trevas desfaço, buscando a luz; \nQue horas de vida, tão doces p\'ra mim, \nJesus me convida, que eu suba p\'ra Si. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Da vida voando, sem nenhum temor; \nAcima buscando do véu o amor; \nQue doce ventura, que aspecto feliz, \nQue nova natura minh\'alma bendiz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do mar o bramido, da brisa o langor \nDa ave o carpido de doce amor, \nMe falam sentidos acordes dos céus, \nMe trazem aos ouvidos os hinos de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minh\'alma ansiosa já quer percorrer \nA senda gloriosa que eu hei de ver; \nQue coisa tão bela, oh! que luz sem véu! \nJesus me revela mistérios do céu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/pensando-em-jesus/',
      ),
      Hino(
        codigo: 156,
        titulo: 'PARA ONDE FÔR, IREI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se eu tiver Jesus ao lado, \nE por Ele auxiliado, \nSe por Ele fôr mandado, \nA qualquer lugar, irei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Seguirei a meu bom Mestre,      (3 vezes)\nOnde quer que fôr, irei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seja meu caminho duro, \nEspinhoso ou inseguro, \nEm seus braços bem seguro, \nAonde me mandar, irei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Males poderão cercar-me, \nOu perigos assustar-me, \nMas se Cristo segurar-me, \nAonde me mandar, irei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando terminar a vida, \nFinda minha triste lida, \nTenho a glória prometida, \nEu pra meu Senhor irei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/308-para-onde-for-irei-/',
      ),
      Hino(
        codigo: 157,
        titulo: 'QUERO O SALVADOR COMIGO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero o Salvador comigo: \nEu sem Ele não posso andar. \nQuero conhecê-Lo perto, \nEm Seus braços descansar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Confiado no Senhor, \nConsolado em Seu amor, \nSeguirei o meu caminho, \nSem tristeza e sem temor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero o Salvador comigo, \nPorque fraca é minha fé! \nSua voz me dá conforto, \nQuando me vacila o pé.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero o Salvador comigo, \nDia a dia em meu viver; \nPela luz e entre sombras, \nNo conflito e no prazer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero o Salvador comigo, \nSábio guia e bom Pastor; \n“Té passar além da morte, \nLonge de perigo e dor”.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 158,
        titulo: 'QUEM TEM JESUS TEM TUDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem tem Jesus tem tudo, \nQuem não tem, não tem nada; \nMas quem tem Jesus Cristo; \nNo céu já tem morada.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quem ama este mundo, \nLá no céu não tem nada, \nMas quem tem Jesus Cristo, \nNo céu já tem morada.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem tem Jesus tem vida, \nQue não se acabará, \nMas quem não tem Jesus \nNo céu não entrará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A riqueza do mundo \nSó traz tribulação, \nFaz ficar orgulhoso, \nE perder a salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No céu há um tesouro \nQue Jesus tem pra dar \nA quem deixar o mundo \nE a Ele se entregar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/quem-tem-jesus-tem-tudo/',
      ),
      Hino(
        codigo: 159,
        titulo: 'QUERO ANDAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu sou fraco e sem vigor \nSem Jesus meu Salvador \nTira todo o meu temor \nAo teu lado Jesus quero andar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ao teu lado quero andar \nSempre mais a te amar \nCada dia quero orar \nSeja assim, meu Jesus, seja assim',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus eu tenho paz \nVida eterna, gozo e luz \nSó Jesus me satisfaz \nQue prazer é andar com Jesus',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a vida eu deixar \nE este corpo se enterrar \nA minha alma em teus cuidados \nConfiarei, meu Jesus confiarei.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 160,
        titulo: 'REFÚGIO VERDADEIRO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seguro estou, não tenho temor do mal; \nSim, guardado pela fé em meu Jesus, \nNão posso duvidar desse amor leal; \nEle em seu caminho sempre me conduz. \nNão me deixará, mas me abrigará, \nDo pecado vil me vem livrar. \nA sua graça não me recusará; \nSim, Jesus é quem me pode sustentar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'No poder de Cristo, o Mestre, \nMinha vida salva está! \nDo perigo que cercá-la \nEle poderá livrá-la; \nSeu poder eterno sempre a susterá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Abrigo eterno tenho no Salvador; \nEle esconde a minha vida em seu poder; \nEu recear não posso do malfeitor \nQue procura pertinaz me enfraquecer. \nConfiado, então, nessa proteção, \nSigo a Cristo e quero ser fiel \nNa minha vida, cheio de gratidão, \nSim, a meu Senhor e Rei Emanuel.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Perigo algum me pode causar temor, \nPois meu Salvador não me abandonará; \nCom sua proteção e com seu amor, \nDirigindo a minha vida ele estará. \nNunca o deixarei, mas fiel serei, \nSempre firme, cheio de fervor; \nA Cristo, Redentor, meu Senhor e Rei, \nEu me entregarei, firmado em seu amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-novo-cantico-igreja-presbiteriana/145-refugio-verdadeiro/',
      ),
      Hino(
        codigo: 161,
        titulo: 'ROCHEDO FORTE É O SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Rochedo forte é o Senhor, \nRefúgio em toda provação! \nConstante e firme Amparador, \nRefúgio em toda provação.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Cristo é nosso abrigo no temporal, \nNa tentação, em todo mal! \nOh! Cristo é nosso abrigo no temporal, \nRefúgio em toda provação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lugar de suave e bom lazer, \nDescanso em toda provação. \nQue vem as forças refazer, \nDescanso em toda provação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Piloto bom no bravo mar, \nConsolo em toda provação! \nAncoradouro singular, \nConsolo em toda Provação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Morreu por nós na dura cruz, \nAuxilio em toda provação! \nEle é eterna e pura luz, \nAuxílio em toda provação!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 162,
        titulo: 'SEGURA NA MÃO DE DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se às vezes problemas da vida parecem insolúveis \nFazendo, até mesmo em momentos, você a chorar \nMas quando é um crente fiel, que se vê em apuros \nSegura na mão de Jesus e comece a cantar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Segura na mão de Jesus             (Bis) \nSegura na mão de Jesus e comece a cantar \nSegura na mão de Jesus             (Bis) \nE todas as lutas da vida você vencerá. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se as trevas te cercam agora parecem intensas \nE já não sentes coragem mais de caminhar \nEleva os teus olhos agora com fé para o alto \nSegura na mão de Jesus e comece a cantar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um dia, bem certo eu sei, findará toda luta \nEspinhos e pedras pra mim sei que não haverá \nPorque Cristo breve, mui breve, levará seu povo \nSegurando na mão de Jesus subirei a cantar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/lidia-de-assis/segura-na-mao-de-jesus/',
      ),
      Hino(
        codigo: 163,
        titulo: 'SOU FELIZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se a paz a mais doce me deres gozar, \nSe dor a mais forte sofrer, \nOh! seja o que for, Tu me fazes saber \nQue feliz com Jesus sempre sou!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'Sou feliz com Jesus! \nSou feliz com Jesus, meu Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Embora me assalte o cruel Satanás, \nE ataque com vis tentações, \nOh! certo eu estou, apesar de aflições, \nQue feliz eu serei com Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu triste pecado, por meu Salvador, \nFoi pago de um modo cabal; \nValeu-me o Senhor, oh! Mercê sem igual! \nSou feliz! Graças dou a Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vinda eu anseio do meu Salvador; \nEm breve virá me levar \nAo céu, onde vou para sempre morar \ncom remidos na luz do Senhor',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/sou-feliz/',
      ),
      Hino(
        codigo: 164,
        titulo: 'SE CRISTO COMIGO VAI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se, pelos vales, eu peregrino vou andar \nOu na luz gloriosa de Cristo habitar, \nIrei com meu Senhor p\'ra onde Ele for \nConfiando na graça de meu Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Se Cristo comigo vai eu irei \nE não temerei, com gozo irei; comigo vai; \nÉ grato servir a Jesus, levar a cruz; \nSe Cristo comigo vai, eu irei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se lá para o deserto Jesus me quer mandar; \nLevando boas novas de salvação sem par; \nEu lidarei, então, com paz no coração. \nA Cristo seguindo sem mais dilação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Será a minha sorte a dura cruz levar, \nSua graça e Seu poder, quero sempre aqui contar. \nContente com Jesus, levando a minha cruz, \nEu falo de Cristo que é minha luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao Salvador Jesus eu desejo obedecer, \nPois na Sua Palavra encontro o meu saber; \nFiel a Deus serei, o mundo vencerei, \nJesus vai comigo, não mais temerei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/515-se-cristo-comigo-vai/',
      ),
      Hino(
        codigo: 165,
        titulo: 'TUDO ENTREGAREI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo, ó Cristo, a Ti entrego; \nTudo, sim, por Ti darei! \nResoluto, mas submisso, \nSempre, sempre, seguirei!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tudo entregarei! \nTudo entregarei! \nSim, por Ti, Jesus bendito, \nTudo deixarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo, ó Cristo, a Ti entrego, \nCorpo e alma, eis aqui! \nEste mundo mau renego, \nÓ Jesus, me aceita a mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo, ó Cristo, a Ti entrego, \nQuero ser somente Teu! \nTão submisso À Tua vontade, \nComo os anjos lá no céu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo, ó Cristo, a Ti entrego; \nOh! eu sinto Teu amor \nTransformar a minha vida \nE meu coração, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo, ó Cristo, a Ti entrego; \nOh! que gozo, meu Senhor! \nPaz perfeita, paz completa! \nGlória, glória ao Salvador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/295-tudo-entregarei/',
      ),
      Hino(
        codigo: 166,
        titulo: 'UM DIA JESUS ACHOU-ME',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um dia Jesus achou-me \nMui longe do meu lar, \nPerdido já no mundo, \nSem mais poder voltar, \nTomou-me em Seus braços, \nSalvou-me Seu olhar. \nAgora andamos juntos, \nDe volta para o lar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A presença de Jesus \nEnche a vida e da-nos luz. \nCada dia acresce \nMais se enriquece \nEsta vida com Jesus',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Atravessamos montes \nPra minha fé provar, \nTão densas são as trevas \nNão posso caminhar. \nNão há menor perigo, \nPois Cristo está comigo, \nE este grande amigo \nConduz-me para o lar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Passamos pelos vales, \nÓ quão é bom lembrar! \nDespertam as saudades \nDo meu paterno lar. \nÓ quão delicioso \nSentir tão alto gozo! \nO amigo precioso \nConduz-me para o lar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/223-jesus-achou-me/',
      ),
      Hino(
        codigo: 167,
        titulo: 'UMA FLOR GLORIOSA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já achei uma Flor gloriosa, \nE quem deseja a mesma terá; \nA Rosa de Saron preciosa \nEntre mil mais beleza terá; \nNo vale de sombra e morte, \nNas alturas de glória e luz, \nEsta Rosa será a minha sorte, \nPrecioso p\'ra mim é Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Precioso p\'ra mim é Jesus! \nPrecioso p\'ra mim é Jesus! \nEu confesso na vida e na morte \nQue tudo p\'ra mim é Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já de muitos foi achada a Rosa \nE provado o excelente odor \nE o poder desta Flor gloriosa \nQue dá vida ao vil pecador. \nMui zeloso pela lei foi Saulo \nPerseguia o povo de Deus, \nMas transformado foi em um Paulo, \nPois achou ele a Rosa dos céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vai buscar a Jesus precioso, \nVai depressa, a noite já vem, \nE, se perdes o amor glorioso, \nSerá triste p\'ra ti o além; \nEsta flor hoje é ofertada \nA quem humildemente a buscar; \nSerá logo da terra tirada, \nPara brilhar em outro lugar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/uma-flor-gloriosa/',
      ),
      Hino(
        codigo: 168,
        titulo: 'AO CÉU EU JÁ VOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Comprado com o sangue de Cristo, \nCom gozo ao céu eu já vou; \nLiberto por graça infinita \nJá sei que Seu filho eu sou,',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu sei, eu sei, \nComprado com sangue eu sou; \nEu sei, eu sei, \nCom Cristo ao céu sim eu vou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou livre da pena e culpa, \nSeu gozo Ele me faz sentir; \nEnche de graça a minha alma, \nCom Ele mui doce é viver.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Cristo eu sempre medito, \nE nunca O posso olvidar, \nGozar Seus favores eu quero. \nVou sempre a Cristo louvar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu sei que me espera a coroa, \nQue Cristo, então, me dará; \nE sei que em breve no céu, \nMinh\'alma com Ele estará.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 169,
        titulo: 'AO ESTRUGIR A TROMBETA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a angelical trombeta neste mundo estrugir, \nO meu nome ouvirei Jesus chamar; \nPois eu creio na promessa, e que Deus a vai cumprir \nQuando ouvir Jesus meu nome proclamar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Glória! Glória! Aleluia! \nO meu nome ouvirei Jesus chamar, \nGlória! Glória! Aleluia! \nEu espero ouvir Jesus a me chamar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando o Céu for enrolado e o sol não der mais luz, \nO meu nome ouvirei Jesus chamar; \nPassarão a terra, o mar, mas permanecerá Jesus, \nQue meu nome vai na glória pronunciar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que música suave há de ser p\'ra eu ouvir \nO meu nome Jesus Cristo anunciar, \nOh! Que gozo vai minha alma lá nos altos céus fruir \nQuando o Cristo o meu nome proclamar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/469-ao-estrugir-a-trombeta/',
      ),
      Hino(
        codigo: 170,
        titulo: 'BREVE JESUS VIRÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Servos de Deus, a buzina tocai; \nJesus em breve virá! \nA todo mundo a mensagem levai; \nJesus em breve virá!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'Breve virá! Breve virá! \nJesus em breve virá!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crentes em Cristo, depressa anunciai; \nJesus em breve virá! \nGratos, alegres, contentes, cantai: \nJesus em breve virá!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Montes e vales, o som ecoai; \nJesus em breve virá! \nOndas do mar a canção entoai: \nJesus em breve virá!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Guerras e fomes nos dão a entender: \nJesus em breve virá! \nPelas catástrofes pode-se ver: \nJesus em breve virá!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/novo-hinario-adventista/breve-jesus-voltara/',
      ),
      Hino(
        codigo: 171,
        titulo: 'BREVE VEREI! O BOM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Breve no Céu, Jesus há de aparecer \nEm gloriosa luz; todos O hão de ver \nNaquele dia, então, eu hei de receber \nDe Cristo galardão; oh! que prazer!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Breve verei o bom Jesus, \nE viverei em plena luz; \nNo lindo Céu eu gozarei... \nDe toda a dor, por Deus, livre serei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na vinda do Senhor irei eu receber, \nDo Seu eterno amor, repouso e prazer, \nDisso, meu bom Jesus, tem-me falado já \nE da celeste luz de Jeová!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na vinda do Senhor desfrutarei prazer, \nQuando meu Salvador em glória aparecer; \nEis que Ele breve vem, os santos levará \nPara a mansão de além, donde virá!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/breve-verei-bom-jesus/',
      ),
      Hino(
        codigo: 172,
        titulo: 'BREVEMENTE PARTIREI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Brevemente partirei para Sião \nPara a Pátria que meu coração deseja, \nPara a Pátria que minha alma sempre almeja, \nCom Jesus partiremos pra Sião.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sairemos deste mundo de horror, \nA tristeza e a dor nós deixaremos \nSubiremos ao encontro do Senhor, \nE com Ele para sempre reinaremos.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis o dia glorioso presto vem, \nNesse dia meu Senhor há de voltar, \nRaiará lá do céu um esplendor, \nÉ Jesus que seu povo vem buscar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Consolai povo meu, diz o Senhor, \nÉ desfeita toda a sua transgressão \nBrevemente sobre as nuvens voltarei \nE meu povo livrarei da aflição.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 173,
        titulo: 'CRISTO VOLTA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Será de manhã no começo do dia \nSerá quando a luz pelas trevas penetra \nQue Cristo há de vir com os anjos em glória. \nReceber deste mundo os seus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ó Jesus salvador, Senhor, \nQuando vamos cantar \nCristo volta! Aleluia! \nAleluia, Amém!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Será na aurora será pela tarde \nSim poderá ser que as trevas da noite \nSe tornem na luz deste brilho de glória \nQuando Cristo os seus receber.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! gozo sem fim quando a noite vencida \nJesus revestir-nos de perpétua vida \nE todos nós formos morar lá na glória \nNesse lar que Jesus preparou.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 174,
        titulo: 'CRISTO VOLTARÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um dia, Cristo voltará; \nAo ascender, o prometeu \nDo modo que subiu virá; \nHá de ver o Rei Jesus, o povo Seu.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Mui breve sim, Jesus virá, \nAlegre O verá Seu povo; \nVelando, todos devem sempre estar, \nA fim de vê-Lo voltar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os mensageiros do Senhor, \nAfirmam que Jesus virá; \nE o Poder Consolador \nAs fiéis promessas nos revelará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! gozo sem comparação \nNo dia do meu Salvador, \nCom a mui grande multidão, \nSubiremos ao encontro do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem-vindo sejas, meu Senhor, \nEm Tua gloriosa luz; \nE nossa fé terá valor; \nNós dizemos: “Ora, vem Senhor Jesus”.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/123/',
      ),
      Hino(
        codigo: 175,
        titulo: 'CRISTO VEM ME BUSCAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo vem me buscar, \nPara o céu me levará, \nO Cordeiro prometido voltará.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ó glória, aleluia! \nMaranata vem Jesus! \nSou liberto pelo sangue dessa cruz. \nVem o Consolador \nSua glória e esplendor! \nSou liberto pelo sangue do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ele manda alerta estar, \nVigiar e sempre orar, \nPara o toque da trombeta escutar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que gozo eu vou sentir, \nCom os anjos a cantar, \nPois com Cristo para sempre vou morar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/cristo-vem-me-buscar/',
      ),
      Hino(
        codigo: 176,
        titulo: 'CRISTO VIRÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Talvez Cristo venha ao romper da aurora, \nCom santos arcanjos, e com voz sonora, \nOs mortos porá dos sepulcros p\'ra fora, \nJesus; breve, vem nos buscar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo, que há de vir, virá! \nEle não tardará, sim, Jesus vem; \nAleluia! Aleluia! Amém! Aleluia! Amém!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Talvez voltará quando o dia feneça. \nOu em uma noite a luz resplandeça, \nIrmãos, esperai que Jesus apareça! \nJesus, breve, vem nos buscar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Seu esplendor e a glória veremos, \nDo mundo, então, nós por fim, sairemos, \nAssim, grande gozo no céu fruiremos; \nJesus, breve, vem nos buscar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/cristo-vira/amem.html',
      ),
      Hino(
        codigo: 177,
        titulo: 'CRISTO, EM BREVE, VEM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O dia vem, a clarear, \nJá fugiu a noite, brilha a luz dalém; \nUm grito soa: aprontar! \nCristo, em breve, vem!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Qual forte vendaval, rugindo sobre o mar, \nEscuta-se a mensagem, que do céu provém; \nOuvi a grande nova, que alegria traz; \n“Cristo, em breve, vem!“',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó povos, tribos e nações \nQue escravizados no pecado estais, \nÓ preparai os corações! \nOh! Por que demorais?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Da morte queiram acordar; \nTrevas e pecados, à luz, hão de fugir; \nEm breve iremos encontrar \nCristo, que há de vir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/cristo-em-breve-vem/',
      ),
      Hino(
        codigo: 178,
        titulo: 'ESTÁ CHEGANDO A HORA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Está chegando a hora de partir \nPrepara-te, ó! Igreja, pra subir, \nVigia sempre firme em oração, \nÉ tempo de real consagração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus em breve vem do Céu \nEm glória majestade e poder, \nMedita ó Igreja de Jesus, \nQue dia glorioso há de ser!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em breve os anjos vão anunciar \nQue Cristo em grande glória vai descer, \nA igreja triunfante subirá \nE os crentes com Jesus irão viver.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E quando estivermos lá no Céu \nEm morte nunca mais se falará \nO gozo alegria e o prazer \nNo Céu eternamente reinará.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/nice-oliveira/esta-chegando-a-hora-de-partir/',
      ),
      Hino(
        codigo: 179,
        titulo: 'FACE A FACE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na presença estar de Cristo, \nEm Sua glória, que será; \nLá no céu, em pleno gozo, \nMinha alma O verá.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Face a face, espero vê-Lo; \nNo além do céu de luz; \nFace a face em plena glória, \nHei de ver o meu Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! que glória será vê-lo; \nQue O possa eu mirar! \nEis, em breve, vem o dia \nQue Sua glória há de mostrar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quanto gozo há em Cristo, \nQuando não houver mais dor, \nQuando cessar o perigo, \nE gozarmos pleno amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Face a face, quão glorioso \nHá de ser o existir, \nVendo o rosto de quem veio, \nNossas almas redimir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/face-face/simplificada.html',
      ),
      Hino(
        codigo: 180,
        titulo: 'FACE A FACE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em breve a vida vai findar;\nAqui não mais eu cantarei,\nPorque no céu irei morar,\nLá na presença do meu Rei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'E face a face vê-lo-ei!\nDe graça salvo, cantarei    (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chegando o dia de esplendor,\nQuando Jesus me vier buscar,\nBem certo estou de que o Senhor\nNo céu a mim dará lugar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ali a voz me soará De Cristo,\neterno Redentor;\n“Fiel, bom servo, bem está;\nDesfruta o gozo do Senhor.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por meu Jesus eu vou viver,\nFazei a minha luz brilhar,\nE cada dia vou fazer\nAquilo que ao Senhor honrar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 181,
        titulo: 'JESUS VOLTARÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo nos mostra que Cristo já volta; \nBreve Jesus voltará! \nJá deste mundo o mar se revolta; \nBreve Jesus voltará.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'Breve virá, breve virá, \nBreve Jesus voltará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristão, acorda, Sua vinda é certa: \nBreve Jesus voltara! \nP\'ra recebê-Lo estás bem alerta? \nBreve Jesus voltará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crente proclama para os pecadores: \nBreve Jesus voltará! \nNão haverá mais tristezas nem dores; \nBreve Jesus voltará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Consola o coração que lhe clama, \nBreve Jesus voltará! \nP\'ra Suas bodas o bom Rei nos chama: \nBreve Jesus voltará.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/jesus-voltara/completa.html',
      ),
      Hino(
        codigo: 182,
        titulo: 'LEVANTAI OS VOSSOS OLHOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Levantai os vossos olhos para cima, \nÓ remidos do Senhor Jesus! \nA figueira mostra que se aproxima \nO Verão; Brotos já produz!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Levantai, levantai! \nVossos olhos para o Céu donde Jesus virá; \nLevantai, levantai! \nA redenção breve se fará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitos dizem que Jesus está tardando, \nPara vir buscar o povo Seu; \nQual nos dias de Noé, estão pecando, \nSem temer o bondoso Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitos, como Faraó, estão dizendo: \n“Quem é o Senhor p\'ra lhe ouvir?” \nE também o coração endurecendo: \nMas as pragas estão p\'ra vir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ser arrebatado, eu, ao Céu, quem dera! \nPois a Igreja Cristo levará. \nA figueira está em flor, é primavera, \nLevantai os vossos olhos já.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/323-levantai-vossos-olhos/',
      ),
      Hino(
        codigo: 183,
        titulo: 'MARANATA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na Palavra está escrito \nQue Jesus Cristo voltará \nE a igreja que O espera \nCom Ele vai encontrar \nMeus irmãos que alegria \nPorque podemos exclamar \nMaranata! Maranata! \nOra Vem Jesus.',
          ),
          TrechoHino(tipo: 'refrao', texto: 'Vem Jesus! Ora vem Jesus!'),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Neste mundo de horror \nPara nós não tem lugar \nEle vai ser destruído \nMas os crentes vão voar \nVoarão sim para a glória \nVão morar no céu de luz; \nMaranata! Maranata! \nOra Vem Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu irmão vigia e ora \nÉ a ordem do Senhor \nBusque o poder de Deus \nQue liberta o pecador \nVamos todos esperar \nA vinda do Rei Jesus \nMaranata! Maranata! \nOra vem Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No dia do arrebatamento \nMuitos crentes vão ficar \nGritando desesperados \nSem poder participar \nDaquela gloriosa festa \nDa igreja com Jesus \nQue durará eternamente \nNo Céu de luz!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 184,
        titulo: 'MANHÃ DO JUIZO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sonhei que a manhã do juízo \nRompeu ao tocar o clarim. \nSonhei que as nações junto ao trono \nReunidas estavam enfim \nUm anjo glorioso descendo \nSe pôs sobre a terra e o mar \nA mão para o céu apontando \nJurou não haver mais tardar',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Milhões de perdidos choravam \nEm clamor, tristezas e ais \nAs rochas bradavam e os montes \nMas, oh! era tarde demais.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O rico surgiu mas, seu ouro \nEm pó a ferrugem desfez \nA conta com Deus contraída \nÉ grande demais desta vez \nEstavam ali poderosos \nNão tinham, contudo, poder \nO livro os anjos acharam \nNenhuma grandeza conter.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vi muitas viúvas e órfãos \nVi ébrios e homens do mal \nTambém quem se enriquecera \nVendendo bebidas fatais. \nDaquele que a Deus procurava \nO anjo seu pranto enxugou \nAos néscios, perversos, impuros, \nA estes, porém, condenou!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/filomena-camillo/manha-do-juizo/',
      ),
      Hino(
        codigo: 185,
        titulo: 'CRISTO CURA, SIM!',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Contra os males deste mundo, \nDeus nos vale só; \nNão há mal que Deus não cure, \nPois de nós tem dó.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo cura, sim, \nCristo cura, sim, \nSeu amor por nós é imenso; \nEle cura, sim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Derramou. Seu sangue puro \nP\'ra remir a mim; \nQuando ungido sou de azeite, \nSou curado, enfim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Só noss\'alma é bem segura, \nOculta em Jesus; \nEle o bálsamo da vida, \nDerramou na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Glória a Deus! Eterna glória, \nDemos-Lhe Louvor; \nGlória, cânticos e hosanas \nDai ao Redentor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/cristo-cura-sim/',
      ),
      Hino(
        codigo: 186,
        titulo: 'NOSSA ESPERANÇA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, sim, vem do Céu, em glória Ele vem! \nEcoa a nova pelo mundo além; \nOh esperança que a Sua igreja tem! \nDai glória a Deus, Jesus em breve vem!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Nossa esperança é sua vinda \nO Rei dos reis vem nos buscar \nNós aguardamos, Jesus, ainda, \nTé a luz da manhã raiar. \nNossa esperança é sua vinda \nO Rei dos reis vem nos buscar \nNós aguardamos, Jesus, ainda,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, sim, vem, os mortos esperando estão; \nO gran momento da ressurreição \nE do sepulcro em breve se levantarão! \nDai glória a Deus, Jesus em breve vem!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, sim, vem do Céu cercado de esplendor, \nAniquilando a corrupção e a dor, \nQuebrando os laços do astuto usurpador, \nDai glória a Deus, Jesus em breve vem!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, sim, vem, completamente restaurar \nO mundo que se arruína sem parar; \nSim, todas as coisas vem depressa transformar \nDai glória a Deus, Jesus em breve vem!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, sim, vem, e sempiterna adoração \nDaremos nós ao Rei de coração; \nAo Grande Autor da nossa eterna salvação, \nDai glória a Deus, Jesus em breve vem!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/300-nossa-esperanca-/',
      ),
      Hino(
        codigo: 187,
        titulo: 'O DIA DO TRIUNFO DE JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando lá do céu descendo, para os Seus, Jesus voltar, \nE o clarim de Deus a todos proclamar, \nQue chegou o grande dia do triunfo do meu Rei, \nEu, por Sua imensa graça, lá estarei!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quando enfim, chegar o dia \nDo triunfo do meu Rei, \nQuando enfim, chegar o dia, \nPela graça de Jesus eu lá estarei!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nesse dia, quando os mortos hão de a voz de Cristo ouvir, \nE dos seus sepulcros todos ressurgir, \nOs remidos reunidos, logo aclamarão seu Rei, \nE, por Sua imensa graça, lá estarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo mundo, rejeitado foi, Jesus, meu Salvador, \nDesprezaram, insultaram meu Senhor, \nMas, faustoso, vem o dia do triunfo do meu Rei, \nE, por Sua imensa graça, lá estarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em mim mesmo, nada tenho em que possa confiar, \nMas Jesus morreu na cruz p\'ra me salvar; \nTão somente nEle espero, sim, e sempre esperarei, \nPois, por Sua imensa graça, lá estarei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-dia-do-triunfo-de-jesus/',
      ),
      Hino(
        codigo: 188,
        titulo: 'O FESTIM DE GLÓRIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que festim de glória para nós há de ser! \nQuando nas brancas nuvens, Cristo aparecer.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Nesse evento mui feliz e de prazer também, \nEu hei de ver meu bom Jesus, Fonte de todo bem.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nesse glorioso dia, o meu corpo mortal, \nSerá como o de anjos, no lar celestial.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que ditosa vinda, a do meu Salvador! \nEu O estou esperando, mui firme em Seu amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Cristo, apressa o dia em que hás de voltar! \nPara ver Tua face eu estou a esperar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 189,
        titulo: 'O REI ESTÁ VOLTANDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O mercado está vazio, \nSeu trabalho já parou, \nO martelo dos obreiros \nSeu barulho já cessou. \nOs ceifeiros lá no campo \nTerminaram seu labor, \nToda terra está em suspense; \nÉ a volta do Senhor!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'O Rei está voltando. \nA trombeta está soando. \nO meu nome a chamar, \nO Rei está voltando \nO rei está voltando \nAleluia, Ele vem me buscar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os vagões de trem vazios \nPassam ruas e quarteirões, \nAviões sem seus pilotos \nVoam para a destruição. \nAs cidades estão desertas, \nSua agitação parou, \nSai a última noticia: \nJesus Cristo já voltou!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vejo a multidão subindo, \nOuço um coro celestial, \nTodo o céu está se abrindo \nNum "benvindo" sem igual. \nComo o som de muitas águas, \nNós ouvimos ecoar \n“Aleluia” ao Cordeiro, \nNós voltamos para o lar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-rei-esta-voltando/',
      ),
      Hino(
        codigo: 190,
        titulo: 'QUÃO GLORIOSO SERÁ O AMANHÃ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quão glorioso será o amanhã \nQuando vier Jesus o Salvador. \nAs nações unidas como irmãs \nBoas vindas darão ao Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não haverá necessidade \nDe luz e esplendor \nNem o sol dará sua luz, \nNem tão pouco o seu calor! \nAli não haverá tristeza, \nNem pranto e nem dor \nPorque lá Jesus o Rei dos Reis, \nPara sempre será o consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Esperamos a manhã gloriosa \nPara darmos boas vindas ao Rei de amor. \nQuando tudo será maravilhoso! \nCom a Santa presença do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O cristão que é fiel e verdadeiro, \nE também um obreiro do Senhor! \nA Igreja Noiva do Cordeiro, \nEstará para sempre com o Senhor.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 191,
        titulo: 'DESEJO DA ALMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Espírito divino, \nGrande ensinador! \nVem! descobre às nossas almas \nCristo, o Salvador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo, Mestre, \nOuve com favor! \nEm poder e graça insigne \nMostre o teu amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem! demole os alicerces \nDa enganosa paz, \nAos errados concedendo \nSalvação veraz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem! Reveste a tua igreja \nDe poder e luz! \nVem! Atrai os pecadores \nAo Senhor Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Maravilhas soberanas \nOutros povos vêem; \nOh! derrama a mesma bênção \nSobre nós também!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/065-vem-espirito-divino/',
      ),
      Hino(
        codigo: 192,
        titulo: 'O DOM CELESTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Assim que Deus me batizou, \nA minha alma viu mais luz, \nPois dom celeste o Pai mandou, \nP\'ra dar louvor ao meu Rei Jesus, \nSou testemunha do meu Senhor, \nE sempre dEle vou falar; \nTambém do selo de amor, \nQue o meu cálice faz transbordar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Louvado seja Jesus, o Cristo, \nQue continua a batizar, \nCom língua estranha, nós temos visto, \nO dom celeste o Pai mandar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O bom caminho vou trilhar, \nSe eu quiser obedecer \nAo Evangelho, à luz sem par, \nAonde vida vou receber, \nDe Jesus Cristo eu falarei, \nQue é dos homens Salvador; \nÓ vinde hoje e recebereis, \nDivina graça do meu Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-dom-celeste/',
      ),
      Hino(
        codigo: 193,
        titulo: 'O BOM CONSOLADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem quer ir, por Jesus, a nova proclamar \nNos antros de aflição, misérias, mal e dor? \nCristãos, anunciai que o Pai quer derramar \nO bom Consolador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'O bom Consolador, o bom Consolador \nQue Deus nos prometeu, ao mundo já desceu; \nÓ ide proclamar, que Deus quer derramar \nO bom Consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No mundo de horror, a luz, enfim, brilhou \nQue veio dissipar as sombras de terror, \nTambém o nosso Pai, aos Seus fiéis mandou \nO bom Consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É o Consolador que traz a salvação \nAos que aprisionou o grande Tentador; \nDizei que veio já, com todo o coração, \nO bom Consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Grande eterno amor! Oh! Gozo divinal! \nQue tenho em proclamar o dom de meu Senhor, \nPois mora já em mim, poder celestial, \nO bom Consolador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-bom-consolador/',
      ),
      Hino(
        codigo: 194,
        titulo: 'A MÃO DO ARADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem sua mão ao arado já pôs, \nConstante precisa ser; \nO sol declina e, logo após, \nVai escurecer. \nAvante, em Cristo pensando, \nEm oração vigiando, \nCom gozo e amor trabalhando. \nP\'ra teu Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não desanimes, por ser tua cruz \nMaior que a de teu irmão; \nA mais pesada levou teu Jesus, \nTe consola, então; \nA tua cruz vai levando, \nComo Jesus perdoando, \nAlegremente andando \nP\'ra o lindo Céu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sê bom soldado de Cristo Jesus, \nSofrendo as aflições, \nNão sufocando a mensagem da cruz, \nNas perseguições; \nVai Seu amor proclamando, \nNovas de paz, sim, levando, \nAos que estão aguardando \nA salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando, enfim, tu largares a cruz, \nJesus te coroará; \nCom santo gozo em glória e luz \nTe consolara. \nEsquecerás teus lidares, \nTribulações e pesares, \nQuando no Céu desfrutares, \nPerfeita paz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-mao-do-arado/',
      ),
      Hino(
        codigo: 195,
        titulo: 'A LUZ DO CÉU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu anseias hoje mesmo a salvação? \nTens desejo de banir a escuridão? \nAbre, então, de par em par teu coração! \nDeixa a luz do céu entrar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deixa a luz do céu entrar! \nAbre bem a porta do teu coração! \nDeixa a luz do céu entrar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo, a luz do céu, em ti quer habitar \nPara as trevas do pecado dissipar, \nTeu caminho e coração iluminar! \nDeixa a luz do céu entrar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que alegria andar ao brilho dessa luz! \nVida eterna e paz no coração produz! \nOh! aceita agora o Salvador Jesus! \nDeixa a luz do céu entrar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/a-luz-do-ceu/',
      ),
      Hino(
        codigo: 196,
        titulo: 'EU ERA TRISTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu era triste, muito triste sem vigor \nVivi perdido, neste mundo enganador, \nAté que um dia, alguém de Cristo me falou; \nQue Ele deu a sua vida prá dar vida a minha alma, \nO seu sangue derramou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim é verdade, Jesus Cristo tem poder, \nEle pode te salvar, se somente Nele crer. \nSim é verdade, Jesus Cristo tem poder, \nEle pode te salvar, se somente Nele crer',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minha tristeza não me deixava viver, \nNão tinha trégua e nem alívio o meu sofrer \nAceitei Cristo, como meu único Salvador \nEle alegrou a minha vida e curou minhas feridas \nQue o pecado provocou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hoje sou livre, para cantar e proclamar \nO Evangelho que pode a todos libertar \nO não rejeites esta mensagem de amor \nVocê pode ser curado, por Jesus ser libertado, \nVenha logo pecador.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/jair-pires/eu-era-triste/',
      ),
      Hino(
        codigo: 197,
        titulo: 'FIRME NAS PROMESSAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Firme nas promessas do meu Salvador, \nCantarei louvores ao meu Criador. \nFico, pelos séculos do seu amor, \nFirme nas promessas de Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Firme, firme, \nFirme nas promessas de Jesus, meu Mestre. \nFirme, firme, \nSim, firme nas promessas de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Firme nas promessas não irei falhar, \nVindo as tempestades a me consternar; \nPelo Verbo eterno eu hei de trabalhar, \nFirme nas promessas de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Firme nas promessas sempre vejo assim \nPurificação no sangue para mim; \nPlena liberdade gozarei, sem fim, \nFirme nas promessas de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Firme nas promessas do Senhor Jesus, \nEm amor ligado com a sua cruz, \nCada dia mais alegro-me na luz, \nFirme nas promessas de Jesus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/firme-nas-promessas/',
      ),
      Hino(
        codigo: 198,
        titulo: 'A DECISÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Dia alegre! Eu abracei \nJesus, e nEle a salvação! \nO gozo deste coração \nEu mais e mais publicarei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Dia feliz! Dia feliz! \nQuando em Jesus me satisfiz! \nJesus me ensina a vigiar, \nE confiando nEle, a orar, \nDia feliz! Dia feliz! \nQuando em Jesus me satisfiz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Completa a grande transação, \nJesus é meu, eu do Senhor! \nChamou-me a voz do Seu amor; \nCedi à imensa atração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Descansa, ó alma! O Salvador \nÉ teu sustento, o pão dos céus; \nE quem possui o eterno Deus, \nResiste a todo o tentador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu sacro voto, excelso Deus; \nDe dia em dia afirmarei; \nE além da morte exultarei, \nTeu filho e súdito dos céus!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/a-descisao/',
      ),
      Hino(
        codigo: 199,
        titulo: 'CONVERSÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! quão cego andei e perdido vaguei, \nLonge, longe do meu Salvador! \nMas do céu Ele desceu, e Seu sangue verteu \nP\'ra salvar a um tão pobre pecador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Foi na cruz, foi na cruz, onde um dia eu vi \nMeu pecado castigado em Jesus; \nFoi ali, pela fé, que os olhos abri, \nE agora me alegro em Sua luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu ouvia falar dessa graça sem par, \nQue do céu trouxe o nosso Jesus; \nMas eu surdo me fiz, converter-me não quis \nAo Senhor, que por mim morreu na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mas um dia senti meu pecado, e vi \nSobre mim a espada da lei; \nApressado fugi, e em Jesus me escondi, \nE abrigo seguro nEle achei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quão ditoso, então, este meu coração, \nConhecendo o excelso amor \nQue levou meu Jesus a sofrer lá na cruz; \nP\'ra salvar a um tão pobre pecador.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/conversao/',
      ),
      Hino(
        codigo: 200,
        titulo: 'DE VALOR EM VALOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pela fé que uma vez me foi dada, \nP\'ra seguir o Cordeiro de Deus, \nPela graça de Deus enviada, \nAndarei, com valor, para os céus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quero andar de valor em valor \nE seguir a Jesus, meu Senhor; \nTé que um dia receba no céu \nA coroa, que me dará Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De Deus quero vestir a armadura, \nP\'ra lutar com coragem e valor, \nPois aqui a peleja é dura, \nContra as hostes do vil tentador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus eu farei mil proezas \nNo combate da fé e do amor; \nNEle tenho vigor e destreza, \nP\'ra lutar e p\'ra ser vencedor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu direi, ao findar esta liça; \nCombati o combate de amor \nE coroa terei de justiça, \nQue no céu me dará o Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/de-valor-em-valor/completa.html',
      ),
      Hino(
        codigo: 201,
        titulo: 'ESTOU SEGURO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que consolação tem meu coração, \nDescansando no poder de Deus; \nEle tem prazer em me proteger; \nDescansando no poder de Deus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Descansando \nNos eternos braços do meu Deus, \nVou seguro, \nDescansando no poder de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sempre avante vou, bem contente estou, \nDescansando no poder de Deus; \nTudo hei de vencer pelo seu poder, \nDescansando no poder de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não recearei, nada temerei, \nDescansando no poder de Deus; \nGozo, paz e amor junto a meu Senhor, \nDescansando no poder de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lutas sem cessar hei de atravessar, \nDescansando no poder de Deus; \nNão me deixará, mas me susterá, \nDescansando no poder de Deus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/estou-seguro/',
      ),
      Hino(
        codigo: 202,
        titulo: 'HOJE SOU FELIZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Perdido foi que Ele me encontrou, \nNeste mundo vil; \nTomou-me, no seu sangue me lavou \nHoje sou feliz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Hoje sou feliz, foi-se o meu temor \nVou permanecer, junto ao salvador, \nFoi-se a escuridão, raia a luz do céu \nPois eu sei que sou de meu Senhor \nE Ele é meu',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se muitas tentações me sobrevém \nPara Ele vou, \nRecebo forças que a mim convém \nSe com Ele estou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se negra noite assustar-me vem \nOuço a Sua voz, \nAs trevas tornam-se na luz do sol \nCom meu Salvador',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/235-hoje-sou-feliz/',
      ),
      Hino(
        codigo: 203,
        titulo: 'JESUS, MEU SALVADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus salvou-me do mundo, \nEle é tão doce p’ra mim; \nAmor, Lhe tenho, profundo, \nPor Sua graça sem fim; \nQuando ia eu no deserto, \nSem gozo, paz e sem luz, \nEle buscou-me, por certo, \nTé que achou-me - Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus, Jesus, Tu és meu Salvador, \nJesus, Jesus, só Teu serei, Senhor \nNa senda mui verdadeira, \nGuia-me Tua mão, \nE ao findar minha carreira, \nReceberei galardão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus de Saron, é a Rosa, \nLírio suave é p’ra mim; \nEle é a Rocha preciosa, \nOnde há gozo sem fim; \nÉ da manhã a Estrela, \nNa noite escura e sem luz, \nTenho doçura em vê-la, \nPois ela é meu Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na manjedoura nascendo, \nNo mundo, só batalhou; \nEm meu lugar padecendo, \nSangue por mim derramou, \nRessurgiu da sepultura, \nSubindo à destra de Deus; \nBreve virá das alturas, \nDescendo em nuvens dos céus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/jesus-meu-salvador/simplificada.html',
      ),
      Hino(
        codigo: 204,
        titulo: 'JUNTO A TI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minha possessão eterna, \nÉs o meu maior amor; \nBem maior que o bem da vida, \nÉs, meu Deus, meu Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Junto a Ti, junto a Ti, \nQuero andar contigo sempre \nNa jornada minha aqui',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O prazer ou o descanso \nNão Te venho suplicar; \nQuero trabalhar sofrendo, \nMas contigo sempre andar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo vale tão sombrio \nE também terrível mar \nQueira tua mão divina \nSempre, sempre me guiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando pelas santas portas \nDa feliz Jerusalém \nEu puder entrar na glória, \nGozarei o eterno bem.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 205,
        titulo: 'JESUS, MEU ETERNO REDENTOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já o Filho de Deus é descido do céu; \nA obra perfeita na cruz consumou; \nE ali Sua carne, rasgada qual véu, \nVivo caminho para o céu nos consagrou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus é meu eterno Redentor! \nPor Seu sangue já remido estou; \nDeu-me paz, poder consolador; \nVivo contente, pois Ele me amou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por Adão, o pecado no mundo entrou; \nNinguém dessa lei se podia libertar; \nMas o filho do homem por nós triunfou, \nN’Ele podemos do mal ressuscitar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do inferno, que paga aos maus, há de dar, \nDo medo da morte, esse dardo cruel, \nDo abismo eterno te pode salvar, \nSó Jesus Cristo, o bom Emanuel.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem alegres buscamos a pátria de amor, \nA qual Deus no céu para nós preparou, \nOnde sempre veremos o nosso Senhor, \nCristo Jesus, que do mal nos libertou.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/jesus-meu-eterno-redentor/completa.html',
      ),
      Hino(
        codigo: 206,
        titulo: 'LIVRE ESTOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu vagava pela senda de horror, \nOprimido pelo pecado e temor, \nQuando o Salvador eu vi, \nSua terna voz ouvi, \nMeu Jesus me libertou por seu amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Livre estou! Livre estou! \nPela graça de Jesus livre estou; \nLivre estou! Livre estou! \nAleluia! Pela fé, livre estou!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu vagava pela senda de horror, \nNão pensando no amor do Salvador; \nEu vagava sem ter luz, \nLonge do Senhor Jesus, \nMas, liberto, hoje canto a Deus louvor,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu vagava pela senda do horror, \nMas, agora quero andar com meu Senhor, \nQuero ouvir sua terna voz, \nE segui-lo sempre após, \nGlória seja dada ao nosso bom pastor.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/livre-estou/',
      ),
      Hino(
        codigo: 207,
        titulo: 'LIVRO DA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As riquezas do mundo \nPouco valem pra mim, \nPois Jesus, no seu reino, \nDá-me vida sem fim; \nE no livro da vida, \nQue conservas aí, \nCerto estou que meu nome \nFoi escrito por Ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Foi escrito por Ti \nO meu nome no céu; \nSim, no livro da vida \nFoi escrito por Ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meus pecados são muitos, \nComo a areia do mar; \nMas Jesus me revela \nSua graça sem par; \nVeio para salvar-me, \nO seu sangue verteu, \nE as delícias eternas \nEle me prometeu',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó cidade festiva, \nRefulgente de luz, \nÉs morada dos santos, \nE fiéis de Jesus! \nSó verá tua glória \nO que crer no Senhor, \nCuja vida foi salva \nPelo seu Redentor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/livro-da-vida/',
      ),
      Hino(
        codigo: 208,
        titulo: 'HORA BENDITA DE ORAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hora bendita de oração! \nQue acalma o aflito coração; \nQue leva ao trono de Jesus \nOs rogos para auxílio e luz! \nEm tempos de cuidado e dor \nMe refugio em meu Senhor; \nSalvo do engano e tentação \nEu folgo na hora de oração.           (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hora bendita de oração! \nQuando a fervente petição; \nSobe ao benigno Salvador \nQue atende à voz do meu clamor \nJesus me ordena a recorrer \nAo seu amor, ao seu poder; \nContente e sem perturbação \nEspero a hora de oração.                (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hora bendita de oração! \nDe santa paz e comunhão! \nDesejo, enquanto aqui me achar, \nCom fé constante, humilde orar; \nE ao fim no resplendor de Deus, \nNa glória dos mais altos Céus, \nMe lembrarei com gratidão \nDe tão suave hora de oração.          (Bis)',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/091-hora-bendita/',
      ),
      Hino(
        codigo: 209,
        titulo: 'NASCER DE NOVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nascestes de novo? Andas já com Deus? \nPertences ao povo, que vai para os céus? \nTens a lei escrita no teu coração? \nEm ti já habita plena salvação?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Se o caminho é estreito, a porta é também, \nTudo está feito, não demores, vem! \nNo portal da vida Cristo acharás, \nAo findar a lida lá no Céu tu estarás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já desceste às águas, passaste o Jordão? \nTens ainda mágoas no teu coração? \nFoste batizado como foi Jesus? \nSegues a Seu lado para o Céu de luz?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O poder vindouro recebeste já? \nTens o teu tesouro preparado lá? \nVida de vitória vives já com Deus? \nMarchas para glória? Andas para os Céus?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao ouvir o brado: “Eis que Cristo vem”, \nTens te preparado p\’ra dizer Amém? \nAlvo é teu vestido, clara é tua luz? \nCanta co\’os remidos - Vem, Senhor Jesus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/nascer-de-novo/simplificada.html',
      ),
      Hino(
        codigo: 210,
        titulo: 'OS BEM AVENTURADOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem-aventurados são \nOs de limpo coração, \nQue não buscam as riquezas para si; \nA tranqüilidade e paz, \nQue desfruta, oh, jamais, \nPoderão discriminadas ser por mim!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh, cantemos aleluia! \nJubilosos, com poder! \nBem alegres, com fervor, \nDemos a Jesus louvor, \nE mais gozo vamos dEle receber!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Grande dita e mui favor \nMe concede meu Senhor, \nPelo Sangue que por mim verteu na cruz; \nTornará também meu ser, \nCheio de veraz prazer, \nSe viver e caminhar na Sua luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao Senhor obedecer, \nD’Ele mesmo me encher, \nPara mim isto é o verdadeiro Céu; \nE por Seu imenso amor, \nPara o pobre pecador, \nQuero aqui, louvá-Lo, e além do véu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quão perfeita é minha paz! \nNão anelo nada mais, \nQuero sempre aqui fazer o Seu querer; \nTenho o amado Salvador, \nE possuo o Seu amor; \nViverei eternamente com prazer!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/os-bem-aventurados/',
      ),
      Hino(
        codigo: 211,
        titulo: 'RESOLUÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, Senhor, me achego a Ti; \nOh! Dá-me alívio mesmo aqui! \nO teu favor estende a mim, \nAceita um pecador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu venho como estou! \nEu venho como estou! \nPorque Jesus por mim morreu, \nEu venho como estou!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As minhas culpas grandes são; \nMas Tu, que não morreste em vão, \nMe podes conceder perdão; \nAceita um pecador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu nada posso merecer, \nTu vês-me prestes a morrer; \nJesus, a Ti me vou render; \nAceita um pecador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sim, venho agora, Redentor; \nSó Tu, Jesus, és meu Senhor; \nOh! Vem salvar-me em teu amor, \nAceita um pecador!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/resolucao/',
      ),
      Hino(
        codigo: 212,
        titulo: 'SENHOR QUE SÃO AQUELES',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Senhor, quem são aqueles \nQue vem sorrindo pelo caminho; \nCantando alegremente, \nComo as aves que vão para o ninho.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Senhor, quem são aqueles, \nQue, em vestes brancas, estão prosseguindo; \nSenhor, eu quero seguí-los, \nTu não me deixes ficar sozinho.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O mundo já não me serve, \nA minha alma está soluçando; \nSenhor, tu não me deixes, \nFicar no mundo sempre sofrendo.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu quero também ser um deles; \nTer felicidade no coração; \nSeguir aquele caminho; \nSem sofrimento e de salvação.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 213,
        titulo: 'SERVIR A JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero eu servir-Te, ó meu Rei Jesus, \nE contigo sempre caminhar na luz, \nTendo com o povo de Deus comunhão \nE dos meus pecados purificação.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim, ó meu Senhor, \nQuero seguir-Te, ó Deus de amor. \nSempre Te servindo, \nE também dando a Ti louvor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No teu bom serviço tenho eu prazer, \nNele muita graça eu vou receber; \nSempre falarei assim do Teu amor; \nE te glorificarei, meu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desça Tua graça sobre mim, Senhor, \nPara trabalhar com mais e mais fervor, \nDá-me entendimento e veraz saber, \nPara alegre, eu fazer o Teu querer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Só em ti confio, meu Senhor e Rei; \nSó em ti vitória eu alcançarei. \nE contigo quero sempre aqui viver, \n“Té que p’ra Sião, me venhas receber.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/servir-jesus/completa.html',
      ),
      Hino(
        codigo: 214,
        titulo: 'SEGURANÇA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que segurança, sou de Jesus! \nEu já desfruto o gozo da luz! \nSou, por Jesus, herdeiro de Deus, \nEle me leva à glória dos céus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Canta minha alma! Canta ao Senhor! \nRende-Lhe sempre ardente louvor!     (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao seu amor, eu me submeti \nE elevado então me senti! \nAnjos descendo trazem dos céus \nEcos da excelsa graça de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sempre vivendo em seu grande amor \nMe regozijo em meu Salvador, \nEsperançoso vivo na luz, \nBondade imensa de meu Jesus',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-para-culto-cristao/que-seguranca-sou-de-jesus/',
      ),
      Hino(
        codigo: 215,
        titulo: 'UM VASO DE BÊNÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero ser um vaso de bênção; \nSim, um vaso escolhido de Deus, \nPara as novas levar aos perdidos, \nBoas-novas que vêm lá dos céus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Faze-me vaso de bênção, Senhor, \nVaso que leve a mensagem de amor! \nEis-me submisso pra teu serviço, \nTudo consagro-Te agora, Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero ser um vaso de bênção, \nPara todos os dias fazer; \nAos culpados que vivem nas trevas, \nO perdão de Jesus conhecer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero ser um vaso de bênção, \nSim, um vaso de bênção sem-par; \nAvisando que crentes em Cristo, \nJubilosos no céu hão de entrar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para ser um vaso de bênção, \nÉ mister uma vida real; \nUma vida de fé e pureza, \nRevestida do amor divinal.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/um-vaso-de-bencao/',
      ),
      Hino(
        codigo: 216,
        titulo: 'UM PECADOR REMIDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Era um pecador, andava sem Jesus, \nNão tinha esperança, nem divina luz; \nHoje sou remido, Cristo me salvou, \nCom o Seu sangue me lavou!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Que amor me concedeu Jesus, \nGozo santo e celeste luz; \nCristo, breve, do céu descerá, \nE consigo, então, me levará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Consolador já veio em mim morar, \nA Palavra santa veio iluminar; \nQuero ser guiado por tão clara luz, \nQue a Cristo me conduz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Jesus amado, vem sem demorar, \nEu estou ansioso p\’ra no céu entrar; \nVem sem mais tardança, faz raiar a luz, \n“Ora vem, Senhor Jesus”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres, pecador, gozar a salvação? \nVem a Cristo, hoje, receber perdão, \nCristo te aceita, pobre pecador, \nNos Seus braços de amor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/um-pecador-remido/',
      ),
      Hino(
        codigo: 217,
        titulo: 'VAMOS PARA O CÉU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos para o céu, ver o bom Jesus, \nSó vai para o céu quem andar na luz, \nA luz é verdade não é fantasia, \nÉ o poder de Deus com sabedoria.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Só entra lavado no sangue de Jesus, \nSó entra lavado no sangue de Jesus, \nNão entra pecado, não entra pecado, \nSó entra lavado no sangue de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não entra pecado, não entra ladrão, \nNão entra inveja nem perseguição; \nNão entra mentira, não entra questão, \nNão entra o crente que zomba do irmão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não entra o homem que vai ao cinema, \nSó entra o que crê no sangue inocente; \nNão entra o homem que bebe aguardente, \nNem qualquer que tenha vícios indecentes.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não entra aquele que faz a questão, \nNo culto ou na escola, com o seu irmão; \nDesobediente, não quer a palavra, \nSó lembra de Deus, quando o pastor fala.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Bíblia do crente é no coração, \nBem purificado, sem murmuração \nDeixando o mundo e o velho Adão, \nAbraçando a Cristo que é a nossa salvação!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cecilia-de-souza/so-entra-lavado/',
      ),
      Hino(
        codigo: 218,
        titulo: 'VEM, INFLAMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu pecado resgatado \nFoi na cruz por teu amor, \nE da morte, triste sorte, \nMe livraste Tu, Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem, inflama viva chama \nEm meu peito, Bem sem fim! \nEu Te adoro, sempre imploro: \nÓ Jesus, habita em mim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se hesitante, vacilante, \nOuço a voz do tentador, \nTu me guias, me auxilias \nE me tornas vencedor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Redimida, só tem vida \nA Minh\’alma em Teu amor; \nCom apreço reconheço \nQuanto devo a Ti, Senhor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/vem-inflama/',
      ),
      Hino(
        codigo: 219,
        titulo: 'A RIQUEZA DIVINAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um dom real Deus despertou \nNos seus fiéis - Dom de curar! \nToda a doença Deus sarou \nE sara ainda e vai sarar; \nPor Jesus, por Jesus, \nOh! Não falhou, nem vai falhar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Que riqueza divinal, \nEu gozo já por fé e luz, \nPor visão triunfal, \nMais gozarei com meu Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'És cego? Crê, que tu verás; \nÉs mudo? Crê, que vais falar; \nÉs surdo? Crê, que ouvirás; \nÉs coxo? Crê, que vais andar; \nFé em Deus, fé em Deus, \nCrê que Jesus te vai curar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De que sofreis? Dos rins, pulmões? \nDe febre, gripe, ou coração? \nDe tosse, nervos, ou lesões? \nDe pele, dentes, defluxão? \nSarareis, sarareis, \nPelo poder da oração!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deixai as capas e vereis, \nAs maravilhas do Senhor! \nTirai a pedra e gozareis \nAs grandes bênçãos do amor! \nFé em Deus, Fé em Deus, \nA Quem rendemos o louvor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a doença a nós vem ter, \nEm Deus devemos confiar, \nPois Jesus Cristo tem poder, \nP\’ra num momento nos curar; \nGlória a Deus, glória a Deus, \nQue é poderoso p\’ra sarar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-riqueza-divinal/',
      ),
      Hino(
        codigo: 220,
        titulo: 'É ASSIM QUE VAI SER',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É aqui neste templo \nQue Deus vai mandar poder \nOs mudos vão falar, e os cegos hão de ver \nCoxos e paralíticos, nós vamos ver andar \nE o povo assustado com o poder pentecostal.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'É assim que vai ser, é assim que vai ser \nAqui no nosso templo que o fogo vai descer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus está ouvindo o clamor das orações \nE o fogo está caindo, alegrando os corações \nÉ tempo de orar sempre, \nE também de vigiar. \nOlhando para Cristo que nos quer santificar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não há enfermidades que Deus não possa curar; \nSe alguém pedir com fé meu Jesus vai responder \nAceita meu amigo este Evangelho de poder \nQue salva e purifica \nA todos que nele crê.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 221,
        titulo: 'JESUS TE QUER CURAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A terna voz do Salvador \nTe fala comovida: \n“Ó vem ao Médico de amor, \nQue dá aos mortos vida”!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo Jesus te quer curar, \nE tem poder p\’ra te curar, \nDos males todos te livrar, \nSe nEle confiares!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crê tu, a quem já Satanás \nHá anos tem ligado; \nA fé te salva, vai-te em paz, \nDe todo o mal curado!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os surdos ouvem, cegos vêem, \nPois Cristo é poderoso! \nOs coxos saram e andam bem, \nPor Seu poder glorioso!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sinais p\’ra sempre seguirão \nAos verdadeiros crentes! \nDemônios, sim, expulsarão, \nE curarão as gentes.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/jesus-te-quer-curar/gtkjgz.html',
      ),
      Hino(
        codigo: 222,
        titulo: 'MÃOS ENSANGÜENTADAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mãos ensangüentadas de Jesus, \nQue foram feridas lá na cruz.          (Bis)',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem tocar em mim, sim, \nVem tocar em mim.                 (4 vezes)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero receber o teu amor, \nE a tua paz que não tem fim! \nQuero receber o teu poder, \nToca-me, Senhor, enche o meu ser.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mãos que os enfermos curou, \nMãos que os paralíticos levantou! \nMãos que os demônios expulsou, \nMãos que as criancinhas abençoou.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 223,
        titulo: 'OS ENFERMOS SÃO CURADOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os enfermos são curados, \nSomente pela fé. \nOs mortos ressuscitados, \nSomente pela fé.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Somente pela fé                         (Bis) \nA casa de Deus vai enchendo \nSomente pela fé',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os leprosos ficam limpos, \nSomente pela fé. \nOs paralíticos andam, \nSomente pela fé.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os mudos também falam, \nSomente pela fé. \nTambém os cegos já vêem, \nSomente pela fé.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os demônios são expulsos, \nSomente pela fé. \nEm nome de Jesus Cristo, \nSomente pela fé.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 224,
        titulo: 'AO PÉ DA CRUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero estar ao pé da cruz, \nDe onde rica fonte \nCorre franca, salutar, \nDo Calvário, o monte.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim, na cruz, sim, na cruz, \nSempre me glorio, \nE no fim vou descansar, \nSalvo, além do rio',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A tremer ao pé da cruz, \nGraça eterna achou-me; \nMatutina Estrela ali \nRaios seus mandou-me.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sempre a cruz, Jesus, meu Deus, \nQueiras recordar-me; \nDela à sombra, Salvador, \nQueiras abrigar-me.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Junto à cruz, ardendo em fé, \nSem temor vigio, \nPois à terra santa irei, \nSalvo, além do rio.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/ao-pe-da-cruz/',
      ),
      Hino(
        codigo: 225,
        titulo: 'ALVO MAIS QUE A NEVE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bendito seja o Cordeiro, \nQue na cruz por nós padeceu! \nBendito seja o Seu sangue, \nQue por nós, ali Ele verteu! \nEis nesse sangue lavados, \nCom roupas que tão alvas são, \nOs pecadores remidos, \nQue perante seu Deus já estão!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Alvo mais que a neve! \nAlvo mais que a neve! \nSim, nesse sangue lavado, \nMais alvo que a neve serei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quão espinhosa coroa \nQue Jesus por nós suportou! \nOh! Quão profundas as chagas, \nQue nos provam quanto Ele amou! \nEis nessas chagas pureza \nPara o maior pecador! \nPois que mais alvo que a neve, \nO Teu sangue nos torna, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se nós a Ti confessarmos, \nE seguirmos na Tua luz, \nTu não somente perdoas, \nPurificas também, ó Jesus; \nSim, é de todo o pecado! \nQue maravilha de amor! \nPois que mais alvo que a neve, \nO Teu sangue nos torna, Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/alvo-mais-que-a-neve/',
      ),
      Hino(
        codigo: 226,
        titulo: 'Ó JESUS, Ó VERA PÁSCOA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Jesus, ó vera Páscoa, \nSuspirada dos antigos! \nÓ Cordeiro eterno e meigo, \nDigna-Te assistir aqui! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bom Jesus, ó Pão divino! \nPela fé Te apropriamos \nÉs nas almas o alimento, \nQue sustenta o nosso amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bom Jesus, ó Vinho puro, \nFonte de perene gozo! \nFaze que nossa alma viva \nPara Ti, de Ti, em Ti.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 227,
        titulo: 'OLHAI P\'RA O CORDEIRO DE DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Livres de pecados vós quereis ficar? \nOlhai p\’ra o Cordeiro de Deus! \nEle morto foi na cruz, p\’ra nos salvar; \nOlhai p\’ra o Cordeiro de Deus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Olhai p\’ra o Cordeiro de Deus, \nOlhai p\’ra o Cordeiro de Deus, \nPorque só Ele vos pode salvar, \nOlhai p\’ra o Cordeiro de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se estais tentados, em hesitação, \nOlhai p\’ra o Cordeiro de Deus! \nEle encherá o vosso coração, \nOlhai p\’ra o Cordeiro de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se estais cansados e sem mais vigor, \nOlhai p\’ra o Cordeiro de Deus! \nEle vos quer dar seu divinal amor, \nOlhai p\’ra o Cordeiro de Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se na vossa senda sombras vêm cair, \nOlhai p\’ra o Cordeiro de Deus! \nEle, com Sua graça, tudo quer suprir, \nOlhai p\’ra o Cordeiro de Deus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/olhai-pra-cordeiro-de-deus/wzkkjh.html',
      ),
      Hino(
        codigo: 228,
        titulo: 'O PÃO DA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Pão da Vida, descido dos céus, \nDá paz, saúde e vigor; \nO Pão celeste, mandado por Deus, \nÉ Cristo, o Salvador; \nÓ Redentor, vem sem tardar, \nDo pecador o mal sanar! \nSe algum perdido buscar Tua luz, \nDepressa vem a paz lhe dar; \nNão tardes mais, amoroso Jesus, \nÓ vem me confortar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há gozo santo p\’ra quem tem a luz, \nEm se lembrar do Seu Senhor, \nÉ só falar do amor de Jesus, \nO grande Redentor! \nTeu jugo é doce, meu Senhor, \nTeu fardo é leve, que amor! \nSe eu não posso levar minha cruz, \nDepressa vem me ajudar; \nNão tardes mais, amoroso jesus, \nÓ vem me confortar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por duras provas e perseguições, \nTu fazes o fiel passar; \nE quem vencer há de ter galardão, \nTambém no Céu lugar, \nEu lá verei Teu esplendor, \nA Tua glória, Salvador; \nSe não puder carregar minha cruz, \nDepressa vem me auxiliar; \nNão tardes mais, amoroso Jesus, \nÓ vem me confortar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, o Teu insondável amor, \nMe faz sentir no coração; \nO amor de Deus, este santo amor, \nE viverei, então; \nA Ti, Jesus, eu dou louvor; \nTu me dás graça e vigor; \nTu és o pão que a vida produz; \nMinh\’alma vem alimentar; \nNão tardes mais, amoroso Jesus \nÓ vem me confortar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-pao-da-vida/gwskwz.html',
      ),
      Hino(
        codigo: 229,
        titulo: 'VEM CEAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo já nos preparou \nUm manjar que nos comprou, \nE, agora nos convida a cear; \nCom celestial maná \nQue de graça Deus te dá, \nVem, faminto tua alma saciar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            '“Vem cear”, o Mestre chama - “vem cear” \nMesmo hoje tu te podes saciar; \nPoucos pães multiplicou, \nÁgua em vinho transformou, \nVem, faminto, a Jesus, “vem cear”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis discípulos a voltar, \nSem os peixes apanhar, \nMas Jesus os manda outra vez partir, \nAo tornar à praia, então, \nVêem no fogo peixe e pão, \nE Jesus, que os convida à ceia vir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem sedento se achar, \nVenha a Cristo sem tardar, \nPois um vinho sem mistura Ele dá; \nE também da vida, o pão, \nQue nos traz consolação; \nEis que tudo preparado já está.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Breve Cristo vai descer, \nE a Noiva receber \nSeu lugar ao lado do Senhor Jesus; \nQuem a fome suportou, \nE a sede já passou, \nLá no Céu irá cear em santa luz.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/vem-cear/',
      ),
      Hino(
        codigo: 230,
        titulo: 'SAUDAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Saudamo-vos, irmãos em Cristo, \nLembrando do que temos visto; \nNesses anos pelas lutas, tentações, \nForam atendidas nossas petições, \nToda glória seja ao nome do Senhor; \nVinde a Ele todos entoar louvor!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Bem alto agora vamos nós cantar, \nQue terra e céus virão nos ajudar. \nAté aqui Deus mesmo nos guiou, \nE com a sua mão nos ajudou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um dia tão glorioso temos, \nE ao nosso Pai agradecemos; \nPois é ele quem nos dá real prazer \nE é fiel em nos guardar e proteger. \nVinde vós, irmãos, conosco a Deus cantar; \nDeste gozo vinde, pois, participar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Alegres hoje jubilemos, \nAo nosso Salvador cantemos; \nEle como filhos seus nos escolheu, \nRicas bênçãos ele já nos concedeu. \nSeja “Avante!” O nosso lema triunfal, \nPois seguimos para o lar celestial!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/saudacao/',
      ),
      Hino(
        codigo: 231,
        titulo: 'SOIS BEM-VINDOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nossas vozes jubilosas \nElevamos com fervor, \nPela vinda amistosa \nDos obreiros do Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sois bem-vindos, \nSois bem-vindos, \nCampeões de Jeová! \nParabéns, mas não fingidos, \nA congregação vos dá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Recebei os lutadores \nDa verdade, do amor, \nDemos a Jesus louvores \nQue os trouxe com vigor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Abraçai os bons soldados \nDas fileiras de Jesus, \nAos que lutam denodados \nPara difundir a luz',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dos fiéis é bem superno \nTrabalhar sem dilação; \nP\’ra fazer que o Rei Eterno \nReine em cada cora',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/sois-bem-vindos/',
      ),
      Hino(
        codigo: 232,
        titulo: 'A FACE ADORADA DE JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desprezando toda a dor eu vou a cantar, \nE o Calvário, ao pecador, sempre apontar; \nFlechas transpassaram-me, padeci gran dor; \nMas Jesus, minha luz, fez-me vencedor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A face adorada de Jesus verei, \nCom a grei amada, no céu estarei, \nNa mansão dourada, hinos vou cantar \nA Jesus, minha luz, que me quis salvar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pode a noite escura ser no servir Jesus, \nMas clamando, com poder, brilhará a luz; \nPodem os laços de Satan, todos, me cercar, \nMas Jesus, pela cruz, faz-me triunfar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando estou a contemplar a montanha além, \nOnde a luta a governar, ‘stá Jesus também, \nQue estende a Sua mão sobre nós dali; \nSei assim, que por mim, Cristo vela aqui.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se entre as ondas estou sem luz, quase a perecer, \nMeu Piloto é Jesus, pode me valer \nO meu barco guia bem pelo bravo mar, \nSim, Jesus me conduz, posso sossegar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-face-adorada-de-jesus/',
      ),
      Hino(
        codigo: 233,
        titulo: 'AVANTE EU VOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus é o Redentor, que veio nos salvar, \nDo mundo de horror, das ondas deste mar; \nA todo o que crê vitória lhe dará, \nTambém real poder, que gozo lhe trará.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Avante eu vou, avante eu vou, \nPara entrar no Céu, na divinal mansão; \nTenho gozo mui profundo; Jesus no coração, \nNão olhando para o mundo, avante eu vou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus meu Salvador, ao Céu me levará, \nE do destruidor, o corpo esmagará, \nAo caro Redentor, fiel aqui serei, \nA Ele, com fervor, somente seguirei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Trombeta soará do nosso Criador; \nA grei se elevará dos santos do Senhor; \nEm glória e poder Jesus regressará, \nSeus servos hão de O ver, pois breve voltará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis que virá Jesus, a fim de me levar, \nA desfrutar em luz, o Seu amor sem par; \nAbraão, Isaque e Jó ali no Céu verei, \nAo lado de Jacó, com eles cearei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/avante-eu-vou/simplificada.html',
      ),
      Hino(
        codigo: 234,
        titulo: 'ARREBATADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Arrebatado fui no dia do Senhor. \nOuvi uma grande voz, a voz do meu Jesus. \nE aos seus pés caí, aos pés do Salvador, \nAquele que por mim morreu na cruz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'E vi um novo Céu, uma nova terra vi. \nUma grande voz do Céu se fez então ouvir, \nNão haverá mais dor, nem pranto, nem clamor \nSó haverá de Deus um grande amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onipotente Deus, a quem vencer dará \nTudo o que é Seu no Céu, tudo herdará de Deus, \nSerei teu eterno Pai, serás meu filho então, \nPois quem vencer alcançará perdão.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/arrebatado-fui/',
      ),
      Hino(
        codigo: 235,
        titulo: 'ALÉM DO CÉU AZUL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Além do Céu azul foi Jesus preparar, \nUm Lar pra dar a quem a vitória alcançar. \nAnelo conseguir a vida no porvir, \nCom fé no meu Senhor Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem sei que eu de mim, nada tenho p\’ra dar. \nMas sei que meu Jesus, já me veio salvar \nAgora quero eu, ter fé no coração. \nAté seu rosto ver além.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando eu chegar ao céu onde reina a luz, \nContemplarei, então, o rosto de meu Jesus, \nProvei o seu amor, minha vida transformou \nPor isso ao céu de luz eu vou!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/alem-do-ceu-azul/',
      ),
      Hino(
        codigo: 236,
        titulo: 'ACORDAI! ACORDAI!',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis marchamos para aquele bom país, \nOnde o crente (sim, é Cristo quem o diz), \nCom seu Salvador p\’ra sempre ali feliz, \nVai com Ele descansar. \nTrabalhemos, pois, com zelo e com vigor, \nConstrangidos pelo Seu imenso amor; \nTrabalhemos pelo nosso Salvador; \nEis que a vida vai findar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Acordai! Acordai! Despertai! Despertai! \nE cantai! Sim, cantai! O Senhor não tardará. \nEis marchamos para aquele bom país, \nOnde o crente (sim, é Cristo quem o diz?), \nCom seu Salvador, p\’ra sempre ali, feliz, \nVai com Ele descansar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis conosco nosso insigne Capitão, \nQue nos assegura eterna salvação! \nEis da santa fé, o invicto pavilhão! \nVamos, vamos trabalhar! \nEis avante! Nada temos que temer; \nPor Jesus, havemos sempre de vencer, \nTrabalhemos, pois até o amanhecer, \nE o trabalho aqui findar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Revestidos da couraça de Jesus, \nComo servos Seus e filhos, sim, da luz, \nGloriando-nos em Cristo e Sua cruz! \nVamos, vamos, trabalhar! \nOs perdidos, vamos com amor buscar, \nAos desesperados, vamos declarar, \nQue Jesus ‘stá pronto todos a salvar! \nÓ sim, vamos trabalhar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/63-acordai-acordai/',
      ),
      Hino(
        codigo: 237,
        titulo: 'BREVE VEM O DIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Breve vem o grande dia \nEm que lutas findarão; \nTodos males, agonias; \nDeste mundo cessarão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cessará no Céu o pranto, \nPois não haverá mais dor, \nE ouvir-se-á  o canto, \nDos remidos do Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que gozo, estar com Cristo, \nEscutando a Sua voz! \nEu almejo hoje isto, \nE segui-Lo sempre após!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se Jesus Cristo é meu guia, \nO Caminho hei de trilhar; \nQuem assim em Deus confia, \nLá no Céu há de chegar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/breve-vem-dia/gtzzhk.html',
      ),
      Hino(
        codigo: 238,
        titulo: 'CANAÃ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O caminho é longo e mau \nNossos pés feridos estão \nInda é longe Canaã                (Bis) \nNo deserto anelando \nMais e mais sua proteção \nEstará inda longe Canaã.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Estamos fracos, tão cansados \nJá viajamos por valados \nPor deserto abrasador \nEstamos fracos, tão cansados \nEstará inda longe Canaã',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nós seguimos por desertos \nO Caminho do cristão \nInda é longe Canaã                (Bis) \nQuantas vezes tem faltado \nNosso leito nosso pão \nEstará inda longe Canaã.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quanto anseia nossas almas \nPor um lar de paz e amor \nInda é longe Canaã                (Bis) \nOnde não há mais pesares \nNão mais pranto nem mais dor \nEstará inda longe Canaã.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Moisés sendo amparado \nPor Deus santo e sua mão \nJá avistamos Canaã                 (Bis) \nPassam margens destemidos \nSem temer o furacão \nEstaremos brevemente em Canaã.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/esta-longe-canaa/',
      ),
      Hino(
        codigo: 239,
        titulo: 'CAMPEÕES DA LUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Soldados somos de Jesus \nE campeões do bem, da luz; \nNos exércitos de Deus, \nBatalhamos pelos céus, \nCantando, vamos combater, \nO vil pecado e seu poder; \nA batalha ganha está; \nA vitória Deus nos dá.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Breve vamos terminar a batalha aqui \nE p\’ra sempre descansar com Jesus ali; \nTodos os que são fiéis ao bom Capitão \nHão de receber lauréis como galardão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Levai o escudo, sim, da fé, \nPois a peleja dura é, \nmas promessa temos nós \nDe jamais lutarmos sós. \nAs flechas do mal não temer, \nMas combater até vencer, \nOlham os campeões p\’ra os céus, \nA vitória vem de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se alguém cansado se encontrar, \nSem forças para pelejar, \nO Senhor quer te ajudar \nA vitória alcançar; \nO mal vencendo avançai, \nE hinos a Jesus cantai, \nE da salvação falai; \nAlmas ao Senhor levai.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/305-campeoes-da-luz/',
      ),
      Hino(
        codigo: 240,
        titulo: 'DESPERTAR PARA O TRABALHO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Posso tendo as mãos vazias, \nCom Jesus eu me encontrar? \nNada fiz, e vão-se os dias \nQue Lhe posso apresentar?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Posso tendo as mãos vazias, \nCom Jesus, eu me encontrar? \nQuantas almas poderia \nAo Senhor apresentar?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não mais temerei a morte; \nVencerei por salvo estar; \nQual será a minha sorte, \nSe no céu vazio entrar?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No celeste lar entrando, \nComo irei ao Salvador? \nQuantas almas vou levando, \nPara meu fiel Senhor?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do pecado, preso em elos, \nPassei anos em vão labor; \nQuem me dera reavê-los, \nP\’ra servir ao meu Senhor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Despertemos, já é dia; \nTrabalhemos, com fervor; \nE levemos, com alegria, \nMuitas almas ao Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/016-despertar-para-o-trabalho/',
      ),
      Hino(
        codigo: 241,
        titulo: 'DESEJAMOS IR LÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nosso Redentor foi preparar \nUm lugar de repouso e esplendor; \nBrevemente chamará para casa a descansar, \nNós, os salvos, do mundo enganador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Desejamos ir lá, \nDesejamos ir lá; \nQue alegria será, \nQuando nós nos encontrarmos lá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nesta terra tesouros não há, \nQue nos possam aqui segurar; \nDesejamos ir ao Céu onde Cristo já está, \nAo lugar onde iremos descansar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Neste lar com Jesus, o Senhor, \nNós havemos de sempre reinar. \nVamos nós ali cantar, cantar hinos de louvor \nAo Cordeiro que veio nos salvar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/desejamos-ir-la/',
      ),
      Hino(
        codigo: 242,
        titulo: 'É MEU O CÉU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que alegria agora, é meu o Céu, \nPois Jesus rasgou o sagrado véu; \nA condenação não mais temerei, \nE meu Redentor sempre louvarei',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Lá no Céu eu descansarei \nCom Jesus, o nosso Rei; \nVem a Deus, ó pecador, \nPois no Céu te espera com amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo mundo eu solitário andei, \nFora de Sodoma o Céu avistei, \nPois olhei p\’ra cima, p\’ra meu Jesus \nQue por mim morreu na sangrenta cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu sou um soldado p\’ra combater, \nE com Deus irei todo o mal vencer; \nA bandeira é o Sangue de Jesus, \nQue por mim vertido foi lá na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando um dia eu venha a parecer, \nSim, meu coração cesse de bater, \nSubirei ao Céu, sem nenhum temor, \nDescansado nos braços do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ante o trono alegre eu estarei, \nE com Deus irei todo o mal vencer; \nHei de ver as palmas da multidão \nQue aleluias a Deus, sempre cantarão.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/e-meu-o-ceu/',
      ),
      Hino(
        codigo: 243,
        titulo: 'ETERNIDADE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se queres viver na eternidade \nÉ preciso crer no Deus da verdade \nSe arrependeres de tanto pecar \nAssim que morrer você vai viver \nNo eterno lar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Pois Cristo é quem diz: “Crê em Deus” \nTambém crê em mim, que sou eu, \nEu fui para o céu preparar \nLugar pra você descansar \nA vida no mundo é cruel \nO homem sem Deus é um réu \nMas crendo em Jesus ele vai \nMorar lá no céu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não queiras ficar no mundo vagando \nJesus Cristo está por ti esperando \nAssim não seria nas trevas sem luz \nVocê nunca vai ao reino do Pai \nSem crer em Jesus',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desejos carnais só trazem amarguras \nPurifique mais sua vida futura \nPorque tu não crês no reino do Pai \nUm dia você vai se arrepender \nE é tarde demais',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinos-avulsos-ccb/se-queres-viver-na-eternidade/',
      ),
      Hino(
        codigo: 244,
        titulo: 'FONTE DE AMOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Fonte de amor perene, \nÉ manancial de luz; \nÁgua da vida corre \nDo trono de Jesus. \nCalmo rio, belo rio, \nQuero estar também \nOnde as águas sempre correm \nDesse rio além! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitos cantar já foram \nCelestes melodias \nAo som de santas harpas, \nEm lindas harmonias! \nSanto rio! Junto ao rio \nVou cantar também, \nOnde as vozes nunca cessam, \nNa Jerusalém!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Límpida fonte jorra, \nBrilhante como a luz, \nÁgua que dessedenta \nQuem crer em meu Jesus. \nCorre rio, calmo corre \nCorra assim a paz \nEm minha alma para sempre \nCorra mais e mais!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/fonte-de-amor/',
      ),
      Hino(
        codigo: 245,
        titulo: 'MUITO ALÉM DO SOL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aqui no mundo não tenho riquezas, \nSei que lá na glória tenho uma mansão, \nQual alma perdida, entre a pobreza, \nDela Jesus Cristo, teve compaixão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Muito além do Sol, \nMuito além do Sol, \nEstá meu lar, o meu lar de escol \nMuito além do Sol.                   (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Assim pelo mundo eu vou caminhando, \nDe provas rodeado, e de tentação, \nPorém, Jesus Cristo, que me está provando, \nLeva-me seguro, à real mansão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A todas as raças do ser humano \nCristo almeja dar-lhes plena salvação, \nQue bela morada, de celeste plano, \nQue tem preparada, na feliz Sião.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/muito-alem-do-sol/',
      ),
      Hino(
        codigo: 246,
        titulo: 'MINHA COROA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu deleite é pensar numa terra de além, \nOnde irei, finda a luta de aquém; \nQuando por meu Jesus conseguir lá chegar, \nNa coroa eu estrelas terei? ',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Na coroa as estrelas preciosas terei, \nQuando o dia de glória raiar? \nQuando Deus me acordar \nE da tumba me erguer, \nNa coroa eu estrelas terei?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No poder de Jesus vou orar e lutar, \nPara ao céu muitas almas guiar; \nQuero, pois, merecer nesse dia final \nA coroa de glória a brilhar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que gozo será o seu rosto mirar, \nE, prostrado aos seus pés, O adorar! \nNa cidade celeste de Cristo, meu Rei, \nA coroa da vida terei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/estrelas-terei/',
      ),
      Hino(
        codigo: 247,
        titulo: 'NAVEGANDO P\'RA TERRA CELESTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'P\’ra terra celeste meu barco andará, \nAli, onde os santos já estão; \nFindando a noite, manhã romperá; \nEntão, os remidos entrarão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim, vou pelas terras, pelos mares também, \nAlerta, Jesus me guiará; Ele prometeu a mim \nNunca deixar-me no mundo, porém, \nSim, levar-me ao porto, com alegria sem fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Será jubiloso esse dia p\’ra mim, \nEm que eu chegar ao céu de luz; \nQue paz e descanso, com Deus, lá sem fim! \nSaúdo-te já, ó meu Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó mundo quer jazes no vil tentador \nNão quero jamais em ti morar \nP\’ra festa celeste eu vou com fervor, \nLouvores a Cristo irei cantar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amigos, lembrai-vos que o naufragar \nÉ fácil p\’ra qualquer um de vós; \nConvite p\’ras bodas, Jesus vos quer dar; \nLugar há bastante para nós.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/navegando-pra-terra-celeste/completa.html',
      ),
      Hino(
        codigo: 248,
        titulo: 'NA JERUSALEM DE DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a luta desta vida \nTrabalhosa se findar, \nO adeus a este mundo vamos dar \nPara o céu então iremos, \nCom Jesus nos encontrar \nNa Jerusalém de Deus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Que gozo e alegria, \nQuando o povo ali chegar, \nEm Jerusalém! Em Jerusalém! \nSempre ali cantando hosanas, \nPois o Rei no trono está, \nNa Jerusalém de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Caminho é extenso, \nMas Jesus vai me guiar, \nQuando pelas provações aqui passar; \nPois olhando nEle, eu sigo. \nPara brevemente estar, \nNa Jerusalém de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao sairmos deste mundo, \nPara a divinal mansão, \nGozaremos a perfeita salvação; \nE Jesus contemplaremos \nA estender-nos sua mão, \nNa Jerusalém de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando, unidos com os salvos, \nLá na Pátria do Senhor, \nContemplarmos a Jesus, o Salvador. \nSempre nos alegraremos \nOnde há perfeito amor; \nNa Jerusalém de Deus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/na-jerusalem-de-deus/',
      ),
      Hino(
        codigo: 249,
        titulo: 'O EXILADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Da linda Pátria estou bem longe; \nCansado estou; \nEu tenho de Jesus saudade. \nOh, quando é que vou? \nPassarinhos, belas flores, \nQuerem m\’encantar; \nSão vãos terrestres esplendores, \nMas contemplo o meu Lar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus me deu a Sua promessa; \nMe vem buscar \nMeu coração está com pressa, \nEu quero já voar. \nMeus pecados foram muitos, \nMui culpado sou; \nPorém, Seu sangue põe-me limpo; \nEu para a Pátria vou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Qual filho de seu lar saudoso, \nEu quero ir; \nQual passarinho para o ninho, \nP\’ra os braços Seus fugir; \nÉ fiel - Sua vinda é certa, \nQuando? Eu não sei. \nMas Ele manda estar alerta; \nDo exílio voltarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sua vinda aguardo eu cantando; \nMeu lar no céu; \nSeus passos hei de ouvir soando \nAlém do escuro véu. \nPassarinhos, belas flores, \nQuerem m\’encantar; \nSão vãos terrestres esplendores, \nMas contemplo o meu lar.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/o-exilado/',
      ),
      Hino(
        codigo: 250,
        titulo: 'O CAMINHO DA CRUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Foi Jesus que abriu o caminho p\’ra o céu; \nNão há outro meio de ir. \nNunca irei entrar no celeste lar \nSe o caminho da cruz errar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Para o céu por Jesus irei, \nPara o céu por Jesus irei, \nGrande é o meu prazer \nDe certeza ter. \nPara o céu pela cruz irei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Certamente eu vou no caminho da cruz \nCom resolução andar. \nÉ desejo meu de gozar no céu \nEssa herança que Cristo deu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os caminhos ímpios do mundo deixei; \nJamais neles vou seguir; \nSigo, pois, Jesus, com a minha cruz, \nNo caminho que ao céu conduz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/o-caminho-da-cruz/simplificada.html',
      ),
      Hino(
        codigo: 251,
        titulo: 'AMOR FRATERNAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, pastor amado, \nContempla-nos aqui; \nConcede que sejamos \nUm corpo só em Ti. \nContendas e malícias \nQue longe de nós vão! \nNenhum desgosto impeça \nA nossa comunhão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois sendo resgatados \nPor um só Salvador, \nDevemos ser unidos \nPor um mais forte amor; \nOlhar com simpatia \nOs erros de um irmão, \nE todos ajudá-lo \nCom branda compaixão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, suave e meigo, \nEnsina-nos a amar, \nE, como Tu, sejamos \nTambém no perdoar! \nAh! Quanto carecemos \nDe auxílio do Senhor! \nUnidos supliquemos \nA Deus por esse amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se tua igreja toda \nAndar em santa união, \nEntão será bendito \nO nome de “cristão”; \nAssim o que pediste \nEm nós se cumprirá, \nE todo o mundo inteiro \nA Ti conhecerá.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/amor-fraternal/',
      ),
      Hino(
        codigo: 252,
        titulo: 'QUANDO O POVO SALVO ENTRAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Anjos aos milhares no Céu, verão \nQuando o povo salvo entrar; \nCrentes coroados também serão, \nQuando o povo salvo entrar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quando o povo salvo entrar, \nQuando o povo salvo entrar, \nMuito grande alegria no Céu haverá \nQuando o povo salvo entrar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os remidos lá hão de se encontrar, \nQuando o povo salvo entrar; \nVestes brancas todos hão de trajar, \nQuando o povo salvo entrar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Todos vencedores, lá hão de estar, \nQuando o povo salvo entrar; \nA tribulação não terá lugar, \nQuando o povo salvo entrar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O “Cordeiro morto”, (que vivo está) \nQuando o povo salvo entrar; \nPara sempre em glória dominará, \nQuando o povo salvo entrar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 253,
        titulo: 'SOU UM SOLDADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou um soldado de Jesus \nE servo do Senhor; \nNão temerei levar a Cruz, \nSofrendo grande dor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Depois da batalha me coroará, \nDeus me coroará; Deus me coroará; \nDepois da batalha me coroará, \nNa celestial mansão; \nLá verei o meu Rei, \nE terei meu galardão, \nDepois da batalha me coroará, \nNa cidade de Sião!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lutaram outros sem temor \nMui forte hei de ser; \nPelejarei por meu Senhor, \nConfiando em Seu poder',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se eu for fiel ao meu Jesus \ne não voltar atrás, \nAlcançarei no Céu de luz, \nLugar de santa paz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/sou-um-soldado-418/',
      ),
      Hino(
        codigo: 254,
        titulo: 'SE EU TIVESSE, NA ALVORADA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se eu tivesse, na alvorada, \nAs asas alvas para voar, \nEu mui contente me trasladava \nPara as fronteiras de Canaã.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Anjos de branco me levariam, \nJunto à presença do meu Senhor, \nE eu com júbilo cantaria, \nCom os já salvos por seu amor \nLá não há pranto nem amargura, \nLá não se sabe o que é dor, \nAli é gozo e alegria, \nAli é tudo puro amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vestido branco, palma e coroa \nCada um deles vai receber \nE se agora a Cristo eu sigo \nJunto a Ele hei de vencer.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Anjos de branco me levariam, \nJunto à presença do meu Senhor, \nE eu com júbilo cantaria, \nCom os já salvos por seu amor \nLá não há pranto nem amargura, \nLá nunca, nunca se diz adeus, \nPorque a morte já foi vencida, \nPor Jesus Cristo nosso Deus.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 255,
        titulo: 'SOU FORASTEIRO AQUI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou forasteiro aqui, em terra estranha estou, \nCeleste pátria, sim, é para onde vou; \nEmbaixador, por Deus, do reino lá dos Céus. \nVenho em serviço do meu Rei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eis a mensagem que me deu, \nQue os anjos cantam lá no Céu; \n“Reconciliai-vos já”, diz o Senhor, Rei meu, \n“Reconciliai-vos já com Deus.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por Deus mandado está que o homem, pecador, \nArrependido já, se chegue ao Salvador, \nPois quem o receber, no Reino vai viver, \nVenho em serviço do meu Rei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mais belo que um rosal o lar celeste tem \nA bênção pra o mortal, o gozo eterno além; \nAli só há prazer, vos manda o Rei dizer: \nVenho em serviço do meu Rei.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 256,
        titulo: 'TENHO SAUDADES DE JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho saudades de Jesus meu Mestre, \nTenho saudades de Jesus meu Rei. \nMas, ao findar o meu labor terrestre, \nMe encontrarei com Ele, sim, eu sei!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Saudades, tenho saudades; \nDe ti Jesus, meu Salvador e Rei, \nQuero sentir a tua presença, \nPois sei que só assim feliz serei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho vontade de viver com Cristo, \nDe nos seus braços sempre me abrigar. \nSim, quero a Ele sempre ser submisso, \nE confiar no seu amor sem par.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não queres tu também viver pra Cristo, \nE Nele sempre, sempre confiar? \nSua presença te dará conforto, \nE seu amor o levará ao lar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 257,
        titulo: 'ATRIBULADO CORAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Atribulado coração, \nEm Cristo alívio encontrarás; \nConsolo, paz e seu perdão, \nSim, dele tu receberás.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh, vem sem demora ao Salvador! \nPor que vacilar e ter temor? \nOh, vem! Vem já! \nDescanso te dará!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dilacerado pela dor \nDas tuas culpas, do pecar, \nVem sem demora ao Salvador, \nE vida nova hás de gozar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se, para vir ao Salvador, \nTu tens fraquezas a vencer, \nOh, vem, pois ele, em seu amor \nE em graça, te dará poder!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Cristo sem demora vem, \nPois ele almeja te valer; \nE sempre quer buscar teu bem; \nConfia nele em teu viver!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/hino-236-atribulado-coracao/',
      ),
      Hino(
        codigo: 258,
        titulo: 'AO FINDAR O LABOR DESTA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao findar o labor desta vida, \nQuando a morte ao teu lado chegar, \nQue destino há de ter a tua alma? \nQual será no futuro teu lar?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Meu amigo, hoje tu tens a escolha: \nVida ou morte, qual vais aceitar? \nAmanhã pode ser muito tarde, \nHoje Cristo te quer libertar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu procuras a paz neste mundo \nEm prazeres que passam em vão, \nMas, na última hora de vida, \nEles não, não te satisfarão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por acaso tu riste, ó amigo, \nQuando ouviste falar em Jesus? \nMas é só Ele o único meio \nDe salvar pela morte na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com tua alma manchada não podes, \nNunca, ver o semblante de Deus; \nSó os crentes com corações limpos \nPoderão ter o gozo nos Céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se tu queres deixar teus pecados, \nE entregar tua vida a Jesus, \nTu terás, sim, na última hora \nUm caminho brilhante de luz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ao-findar-labor-desta-vida/',
      ),
      Hino(
        codigo: 259,
        titulo: 'FIDELIDADE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por meus delitos expirou \nJesus a vida e luz. \nEle o castigo meu levou \nNa ensanguentada cruz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Faz-me forte em confessar \nA Ti Jesus, Senhor! \nOh! Faz-me pronto a confiar \nem teu excelso amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E eu hei de ter tão fraca voz, \nQue trema a confessar \nA quem, com morte tão atroz, \nMinha alma quis salvar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois eu desejo aqui cantar \nTão grande salvador; \nE, quando for no céu morar, \nLouvá-lo-ei melhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-aleluia/por-meus-delitos-expirou/',
      ),
      Hino(
        codigo: 260,
        titulo: 'ABANDONA ESTE MUNDO DE HORROR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Abandona este mar, \nOnde podes naufragar; \nAbandona este mundo de horror, \nA maré te levará, \nO teu barco quebrará, \nÓ aceita a Jesus, o Salvador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Abandona já duma vez, \nEste proceloso mar. \nHoje sem tardar, \nDo castigo eternal, \nE de morte tão fatal, \nFoge logo pecador com rapidez.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis faróis a clarear \nE perigos a marcar, \nAbandona este mundo de horror, \nJá na barra mais além, \nO teu barco se sustém, \nÓ aceita a Jesus, o Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis que vozes sem cessar, \nNão se cansam de clamar; \nAbandona este mundo de horror, \nÓ amigo, ouve já, \nEssa voz te salvará. \nÓ aceita a Jesus, o Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não escutas a Jesus, \nQue te chama para a luz? \nAbandona este mundo de horror, \nSe persistes em vagar, \nNão te poderás salvar. \nÓ aceita a Jesus, o Salvador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/abandona-este-mundo-de-horror/',
      ),
      Hino(
        codigo: 261,
        titulo: 'AO LAR PATERNAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero vos contar a história dum varão, \nQue Jesus outrora relatou, \nO qual tinha dois filhos em feliz mansão, \nTé que o mais jovem o deixou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Filho desleal ao lar paternal, \nQueiras hoje regressar! \nPois o Pai está por ti esperando lá; \nPecador, ó volta p\’ra teu lar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O mais moço disse ao seu bondoso pai: \n“A herança minha queiras dar”; \nE a sua fazenda, alegremente vai \nNum país distante desfrutar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O incauto jovem os seus bens esbanjou \nCom seus camaradas, no prazer; \nEis que vindo a fome, do seu pai se lembrou \nQue pudera sempre o suster.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O perdido filho, ao lar por fim, voltou, \nMui arrependido do que fez; \nE o pai contente, amoroso o beijou, \nPois seu filho via outra vez!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 262,
        titulo: 'CANSADO E OPRIMIDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó pecador, tu tens tristeza n\’alma, \nPor que não dás a Jesus teu coração? \nVives cansado, abatido e frágil, \nSem ter pedido a Deus o Seu perdão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus está chamando, \nA Ele venha como estás \nEle te dará alegria neste mundo, \nE lá no outro vida eterna e paz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A tua alma é coisa preciosa \nQue o inimigo não deve cobiçar, \nSomente Cristo tem direito em tua alma, \nPara um dia lá no céu morar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se hoje choras, não te desanimes, \nPorque Jesus te consolará \nEle é o refúgio dos cansados e oprimidos \nEle é o guia que ao Pai conduzirá.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/jesus-esta-chamando/',
      ),
      Hino(
        codigo: 263,
        titulo: 'CRISTO VAI PASSAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há hoje alguém esperando \nPara Jesus encontrar? \nVenha, sem mais demorar-se, \nCristo vai hoje passar! \nEi-lo de mãos estendidas, \nCheio de graça sem-par; \nOh! Que ventura inaudita \nCristo vai hoje passar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo vai hoje passar, passar, passar! \nPassa de amor transbordando, \nTodos a Si convidando. \nO Mestre vai hoje passar, \nSim, hoje Ele vai passar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há inda alguém duvidando \nDo seu poder de salvar? \nPois venha experimentá-lo, \nCristo vai hoje passar! \nO seu poder é divino, \nO seu amor é sem-par. \nÓ coração quebrantado! \nCristo vai hoje passar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há inda alguém demorando \nPara Jesus aceitar? \nEis que o Senhor está perto, \nEle vai hoje passar! \nÓ pecador desditoso, \nNão cesses, pois, de clamar! \nVem tuas culpas chorando; \nCristo vai hoje passar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/cristo-vai-passar/',
      ),
      Hino(
        codigo: 264,
        titulo: 'CHORA AGORA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pecador, confessa e chora \nTeus pecados, sem tardar; \nOlha bem que o tempo foge, \nÉ perigo demorar. \nLouco estás se não te emendas, \nSabes que te há de julgar \nUm Deus reto e justiceiro \nQue te pode condenar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chora agora as tuas culpas, \nVai a Deus as confessar; \nE se não, sem mais remédio \nTarde então hás de chorar. \nAh! Se a dor aqui te aflige, \nComo então hás de sofrer \nNo tormento, sem alívio, \nPara sempre a padecer?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com remorso e pranto tarde \nTu dirás: “Eu infeliz! \nEu perverso e desgraçado! \nDeus chamou-me e eu não quis.” \nOuve a Deus, escuta agora, \nSim, enquanto a vida der; \nPois naquele grande dia \nJusticeiro Ele há de ser.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 265,
        titulo: 'CRISTO TE CHAMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo te chama com mui terno amor: \nÓ pecador, vem atender! \nDÊle não fujas com fútil temor; \nVem a Jesus te render.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ó pecador, eis o Senhor! \nVem, atende com fé a chamada de amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo te chama pra vir descansar; \nÓ pecador, vem atender! \nTeu grande peso te quer minorar; \nVem a Jesus te render!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo deseja, pois, te perdoar; \nÓ pecador, vem atender! \nTudo Ele fez para te resgatar; \nVem a Jesus te render!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo de novo se põe a chamar; \nÓ pecador, vem atender! \nCorre depressa, sim, vem-te entregar, \nNada te deve deter!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/182-cristo-te-chama/',
      ),
      Hino(
        codigo: 266,
        titulo: 'CRISTO SALVA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo salva o pecador, \nLava o negro coração; \nAo contrito, com amor, \nOferece salvação.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Confiai em seu poder; \nConfiai em seu amor; \nCrede, pois, que Cristo quer \nLibertar o pecador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo salva o pecador \nE concede-lhe perdão. \nAceitai o bom Senhor; \nAceitai de coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vinde todos, e achareis \nPaz e luz no Redentor; \nVinde, e então recebereis \nVida eterna do Senhor.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 267,
        titulo: 'DEIXA ENTRAR O REI DA GLÓRIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ouves tu? Jesus te chama \nSim, te chama, ó pecador! \nA Jesus, que salva e ama, \nVem agora, sem temor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deixa entrar o Rei da glória \nEm ti mesmo, ó pecador; \nQuem é este Rei da Glória? \nÉ Jesus, o teu Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para o mundo e o pecado \nTens no coração lugar, \nMas Jesus ressuscitado, \nTu não podes abrigar?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do prazer, a vista linda, \nDeste mundo sedutor, \nSim, um dia aqui se finda, \nCom a morte, ó pecador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hoje é dia aceitável \nPara vires t\’entregar \nA Jesus, que mui amável, \nQuer, e pode te salvar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/deixa-entrar-rei-da-gloria/',
      ),
      Hino(
        codigo: 268,
        titulo: 'A COLHEITA FINDOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A colheita findou, o verão já passou, \nDescanso os ceifeiros terão; \nNão mais brilha a luz, do evangelho da cruz, \nOs salvos na glória estão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quando o tempo passar e a ceifa findar, \nIndo ao tribunal \nPara Cristo encontrar, \nQual juízo tu receberás?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não mais cantarão, hinos de salvação, \nO tempo da graças passou, \nEntão o pecador, sem ter o Salvador, \nO eterno castigo ganhou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os remidos s\’tarão, onde a Deus verão, \nNão há mais tristeza e dor, \nE louvores darão, pois não creram em vão; \nEm Cristo Jesus, Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onde hás de ficar, Tu que vives sem lar \nE no triste pecado sem Deus, \nQuando Cristo voltar, para o mundo julgar, \nTerás tu um lugar lá nos céus?',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 269,
        titulo: 'BENDITOS LAÇOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Benditos laços são os do fraterno amor, \nQue assim, em santa comunhão, \nNos unem no Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao mesmo trono vão as nossas petições; \nÉ mútuo o gozo ou aflição \nDos nossos corações',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aqui tudo é comum, o rir e o chorar. \nEm Cristo somos todos um \nNo gozo e no lidar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se desta santa união nos vamos separar, \nNo Céu eterna comunhão \nHemos com Deus gozar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 270,
        titulo: 'MANSO E SUAVE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Manso e suave Jesus está chamando, \nChama por ti e por mim; \nEis que às portas espera velando, \nVela por ti e por mim',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem já, vem já! \nEstás cansado; vem já, \nManso e suave, Jesus está chamando; \nChama: Ó pecador, vem!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que esperamos? Jesus convidando, \nConvida a ti e a mim. \nPor que desprezas mercê que está dando, \nDando a ti e a mim?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O tempo corre, as horas se passam, \nPassam pra ti e pra mim; \nMorte e leitos de dor presto chamam. \nChamam a ti e a mim;',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/manso-suave/simplificada.html',
      ),
      Hino(
        codigo: 271,
        titulo: 'NÃO VOS DEMOREIS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não vos demoreis, Jesus vos chama, \nEle vos chama com amor \nNão vos demoreis, Jesus vos chama \nEle acalma a vossa dor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não vos demoreis, Não vos demoreis! \nVinde sem temor, \nQuem vos chama é Jesus, \nQue morreu por nós na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não vos demoreis, perdão alcança \nQuem confia no Senhor \nNão vos demoreis, e sem tardança \nRecebei o Redentor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não vos demoreis, Jesus foi morto, \nE remiu ao pecador. \nNão vos demoreis, paz e conforto \nQuer-vos dar o Salvador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/227-nao-vos-demoreis/',
      ),
      Hino(
        codigo: 272,
        titulo: 'QUERES O TEU VIL PECADO VENCER',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres o teu vil pecado vencer? \nDá teu coração a Jesus. \nQueres também seu favor receber? \nDá teu coração a Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Já chega de hesitação! \nJá chega de oposição! \nOh! Busca em Cristo o perdão, \nE dá-lhe teu coração!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em santidade desejas viver? \nDá teu coração a Jesus. \nQueres do Espírito Santo o poder? \nDá teu coração a Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A tempestade não quer acalmar? \nDá teu coração a Jesus. \nQueres as tuas paixões refreiar? \nDá teu coração a Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dos teus amigos alguém te traiu? \nDá teu coração a Jesus. \nBusca a amizade de quem te remiu? \nDá teu coração a Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres no céu a teu Deus exaltar? \nDá teu coração a Jesus. \nQueres a glória divina alcançar? \nDá teu coração a Jesus.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 273,
        titulo: 'RÉGIO HÓSPEDE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tendes vós lugar vazio \nPara Cristo, o Salvador? \nEle bate e quer entrada, \nQuer salvar-vos em amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Dai lugar a Jesus Cristo! \nIde já O convidar, \nPara que ache em vós morada \nE onde sempre possa estar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vós quereis divertimentos, \nAmizades e prazer, \nMenos esse amigo vero \nQue por nós ousou morrer?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tendes tempo para Cristo? \nLogo O buscareis em vão! \nHoje é tempo favorável \nDe aceitar a salvação!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 274,
        titulo: 'SEGUE-ME',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Escuta a voz do bom Jesus: \n“Segue-Me, vem, segue-Me. \nGuiar-te-ei à eterna luz; \nSegue-Me, vem, segue-Me. \nPor ti Eu toda a lei cumpri; \nPor ti o amargo fel bebi; \nPor ti a morte já sofri; \nSegue-Me, vem, segue-Me.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Liberto dos pecados teus, \nSegue-Me, vem, segue-Me. \nGuiar-te-ei aos altos céus; \nSegue-Me, vem, segue-Me. \nOh! Quantas vezes te chamei, \nE tu quebraste a minha lei; \nMas fiador teu Eu fiquei; \nSegue-Me, vem, segue-Me.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Em Mim tu podes descansar; \nSegue-Me, vem, segue-Me. \nVem teus cuidados Me entregar; \nSegue-Me, vem, segue-Me. \nEu sou teu Deus, teu Salvador; \nEu te amo muito ó pecador; \nOh! Deixa todo o teu temor; \nSegue-Me, vem, segue-Me.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Sim, meu Jesus, Te seguirei; \nSeguirei, sim, seguirei; \nPor Ti eu tudo deixarei; \nDeixarei, sim, deixarei. \nMui débil sou, e sem valor; \nSem Ti não posso andar, Senhor; \nMas enche-me do teu vigor! \nSeguirei, sim seguirei.”',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/217-segue-me/',
      ),
      Hino(
        codigo: 275,
        titulo: 'TAL QUAL ESTOU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tal qual estou, eis-me, Senhor. \nPois o teu sangue remidor \nVerteste pelo pecador; \nÓ Salvador, me achego a Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tal qual estou, sem esperar \nQue possa a vida melhorar; \nEm Ti só quero confiar; \nÓ Salvador, me achego a Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tal qual estou, e sem poder, \nAs faltas podes preencher \nE tudo quanto me é mister; \nÓ Salvador, me achego a Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tal qual estou me aceitarás, \nE tu minha alma limparás, \nCom teu amor me cobrirás; \nÓ Salvador, me achego a ti!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 276,
        titulo: 'VINDE, PECADORES',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vinde todos pecadores \nA Jesus, o Salvador; \nVinde logo, sem temores, \nEncontrar o Redentor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sim eu sei; Oh! Eu sei, \nCristo salva o perdido pecador! \nSim, eu sei; oh! Eu sei, \nCristo salva o perdido pecador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dá aos fracos, fortaleza; \nDas montanhas planos faz, \nAo deserto dá beleza, \nE aos crentes, luz e paz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nas fraquezas, ei-Lo perto, \nDominando a força má; \nNo caminho, guia certo, \nE Sua graça sempre dá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho gozo mui superno \nPelo Sangue que verteu, \nNem o mundo, nem o inferno, \nTira a vida que me deu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando Cristo vier na glória \nA buscar o povo Seu, \nCantaremos a história, \nDo amor de Deus, no céu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vinde-pecadores/',
      ),
      Hino(
        codigo: 277,
        titulo: 'VEM Ó PRÓDIGO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, ó pródigo, vem sem tardar te chama Deus, \nOuve-O chamando, sim, chamando a ti; \nTu, que vagas errante escuta a voz dos céus, \nÓ escuta a voz de amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deus espera por ti, \nPerdido, pródigo, vem; \nDeus espera por ti, \nPerdido, pródigo, vem.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com paciência e ternura te chama o Senhor, \nOuve-O chamando, sim, chamando a ti; \nVem enquanto te chama o meigo Salvador, \nÓ escuta a voz de amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá na casa do Pai, abundância há de pão; \nOuve-O chamando, sim, chamando a ti; \nJá está pronta a mesa com toda a provisão, \nÓ escuta a voz de amor!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 278,
        titulo: 'VEM A CRISTO, MESMO AGORA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem a Cristo, mesmo agora, \nVem assim tal qual estás. \nQue Dele sem demora, \nO perdão obterás. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crê em Cristo, sem detença: \nNa cruz por ti morreu; \nSó quem tem tal crença \nTem entrada no Céu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Onde emana mel e leite \nTe espera o seu amor; \nNão temas que rejeite \nAo maior pecador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ele anela receber-te \nE Sua graça te dar \nQuer consigo ver-te, \nE contigo habitar',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 279,
        titulo: 'VEM AO PASSO DAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com teu pecado vem já p\’ra Jesus, \nEle te quer perdoar, \nDeixa as trevas, vem já para a luz; \nVem tua vida salvar,',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem! Vem! Vem o passo dar! \nVem teu coração entregar \nVem já dizer. “Jesus me salvou, \nDo meu pecado limpo estou”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Contra o pecado outra fonte não há, \nSó Jesus pode limpar; \nDos teus temores e culpas, vem já \nNEle te refugiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que oferta por ti fez Jesus, \nPara te purificar! \nDeu o Seu Sangue no alto da cruz; \nVem tua alma lavar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem dar o passo, sem hesitação, \nJesus te quer perdoar; \nAgora mesmo toma a salvação \nVem tua vida salvar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 280,
        titulo: 'VEM A DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, enquanto Deus te chama \nE tu sentes Seu amor, \nPois do Céu poder derrama \nP\’ra salvar o pecador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem a Deus, a Jesus, entregar teu coração; \nE terás Sua luz A perfeita salvação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se da vida tens o fardo \nE tu\’alma triste está, \nCrê em Deus, não sejas tardo, \nQue Jesus te salvará!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Neste mundo vais andando, \nSem tranquilidade e paz; \nVolta a Deus, mas confiando, \nE feliz então serás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem a Cristo, que te espera, \nNão demores, pecador! \nNos Seus braços Deus quisera \nReceber-te com amor!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/vem-deus/',
      ),
      Hino(
        codigo: 281,
        titulo: 'VEM, FILHO PERDIDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem,  filho perdido, \nÓ prodigo, vem! \nRuína te espera \nNas trevas além. \nTu, de medo tremendo, \nE de fome gemendo.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ó filho perdido, \nVem, pródigo, vem! \nVem! Vem! Pródigo ,vem!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, filho perdido, \nÓ pródigo, vem! \nTeu pai te convida, \nQuerendo-te bem! \nVestes há para ornar-te, \nRicos dons, vem fartar-te! \nÓ filho perdido',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, filho perdido, \nSim, volta a Jesus! \nBondade infinita \nSe avista na cruz. \nEm miséria vagando, \nTuas culpas chorando! \nÓ filho perdido',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó pródigo, escuta \nAs vozes de amor! \nOh, rompe as ciladas \nDo vil tentador, \nPois em casa há bastante, \nE tu andas errante! \nÓ filho perdido.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/vem-filho-perdido/',
      ),
      Hino(
        codigo: 282,
        titulo: 'VEM JÁ, O PECADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pecador, vê a luz, brilha para ti, \nLá da cruz do Salvador, \nOnde a vida deu; e do lado Seu \nCorre sangue redentor',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ó vem já, como estás! \nVem agora, ao Salvador; \nSua vida deu, tudo padeceu; \nNão demores! Vem já, pecador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na escuridão do Jardim orou \nTão aflito meu Senhor; \nQuando pranteou, sangue Seu suou, \nNo Getsêmani em dor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vê o Salvador co\’as feridas mãos \nTe chamando, ó pecador! \nVida eterna têm os que nEle crêem \nE aceitam o Seu amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem a Cristo, vem confessando, já, \nTeus pecados, e te ouvirá, \nE no coração sentirás o perdão, \nPois Jesus te perdoará.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vem-ja-pecador/',
      ),
      Hino(
        codigo: 283,
        titulo: 'ALELUIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A mensagem do Senhor; aleluia! \nÉ cheia de perdão e amor! \nCristo salva o pecador; aleluia! \nSalva até por meio de um olhar!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh, olhai, pois, e vivei! \nConfiai só em Jesus! \nEle salva o pecador; aleluia! \nSalva até por meio de um olhar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vossa culpa já levou; aleluia! \nJesus a satisfez na cruz; \nSua vida já entregou, aleluia! \nPara vos apresentar a Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sua graça nos legou; aleluia! \nEterna vida lá nos céus; \nConfiai só em Jesus; aleluia! \nConvertei-vos hoje mesmo a Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aceitai a salvação; aleluia! \nSegui os passos do Senhor; \nProclamai o seu perdão; aleluia! \nExaltai o grande Redentor!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 284,
        titulo: 'ALMA CANSADA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Alma cansada \nNão desesperes, espera em Deus \nQue Ele vem, que Ele vem te socorrer. \nAlma cansada, \nNão desesperes, espera em Deus, \nEspera em Deus, espera em Deus \nE no seu poder.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Alma cansada, \nEspera em Deus, e no seu amor. \nVem, alma cansada, espera em Deus, \nConfia somente no seu amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Alma cansada, \nO teu lamento não resolverá. \nA hora é triste, com fé insiste, Deus te ouvirá. \nSe teus momentos trazem tormentos \nQue fazem chorar, \nDeus te chama agora. \nOh! Vem sem demora em paz descansar.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/jair-pires/alma-cansada/',
      ),
      Hino(
        codigo: 285,
        titulo: 'BRILHA NO VIVER',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não somente pra fazer um feito singular \nÉ mister agir com muito ardor, \nMas as coisas mais humildes por executar \nDeves fazê-las com fervor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Brilha no meio do teu viver,               (Bis) \nPois talvez algum aflito possas socorrer, \nBrilha no meio do teu viver',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Talvez alguma vida possas alegrar \nCom palavras doces, em amor; \nOu talvez algumas almas tristes alcançar \nCom a mensagem do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por maior que seja teu esforço a exercer, \nPor mais firme a tua devoção, \nEm redor, oh! Quantas almas vivem sem prazer! \nJazem na negra escuridão.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-presbiteriano-novo-cantico/320-brilha-no-viver/',
      ),
      Hino(
        codigo: 286,
        titulo: 'DEUS AMOU ESTE MUNDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus amou de tal maneira \nEste mundo sofredor, \nQue a humanidade inteira, \nDeu Seu filho para Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'E agora nunca mais perece \nO que crê, mais vida eterna tem; \nQuem em Cristo permanece \nVai ser coroado além. \nO pecado na cruz foi vencido, \nPodes, pela fé, vencer também; \nDe justiça, ó sê vestido, \nE receberás coroa além.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Prisioneiro do pecado \nVagas sem esperança ter; \nMas Jesus foi enviado, \nPara liberdade te trazer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu que vives desviado \nSem a paz de Deus gozar, \nOuve a voz do Pai amado, \nQue te espera para te abraçar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/deus-amou-de-tal-maneira/',
      ),
      Hino(
        codigo: 287,
        titulo: 'DAI-NOS LUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Uma voz ressoa de geral clamor: \nDai-nos luz! Dai-nos luz! \nOs milhões em trevas, cheios de pavor, \nPedem luz, pedem luz!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Dai-nos luz, a mui gloriosa luz \nDe perdão, de paz e amor! \nDai-nos luz, a tão preciosa luz \nDe Jesus, o Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ansiamos vida, paz, consolação; \nDai-nos luz! Dai-nos luz! \nSe é por Cristo só que Deus nos dá perdão, \nDai-nos luz! Dai-nos luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sim, por toda parte deve reluzir \nEssa luz de Jesus, \nQue ilumina a estrada que hemos de seguir. \nDai-nos luz! Dai-nos luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eia, pois, ó crentes, todo o mundo encher! \nDessa luz de Jesus! \nAos milhões perdidos sem tardar valei. \nCom a luz de Jesus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/311-dai-nos-luz/',
      ),
      Hino(
        codigo: 288,
        titulo: 'DEIXA PENETRAR A LUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se ao inimigo temes combater, \nSe estás em trevas e não tens poder, \nQue a formosa luz de Deus fulgure em ti; \nE serás feliz, assim.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deixa penetrar a luz! \nDeixa penetrar a luz! \nQue a formosa luz de Deus fulgure em ti; \nÉ serás feliz assim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se a tua fé é fraca no Senhor, \nE não mostras fruto ou nenhum fervor, \nQue a formosa luz de Deus fulgure em ti \nE serás feliz assim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se na luz estamos, que divina luz! \nSe nos limpa sempre o sangue de Jesus, \nTemos claridade em nosso coração, \nE vivemos nós na luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se de Deus o Espírito Consolador, \nTraz a luz do céu, divino resplendor, \nPenetrando Ele, no teu coração, \nViverás então de amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se alegre fores à mansão sem par, \nÓ enfrenta as trevas, que vão se afastar, \nQue a formosa luz de Deus fulgure em ti, \nE serás feliz assim.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/deixa-penetrar-luz/',
      ),
      Hino(
        codigo: 289,
        titulo: 'É FRANCA A PORTA DIVINAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É franca a porta divinal, \nAberta a todo o mundo; \nPor ela o pecador mortal \nAvista amor profundo!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Graça imensa pois assim \nA porta aberta fica a mim. \nA mim, a mim, \nAberta fica a mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Entrai de toda a condição, \nGraça e perdão pedindo! \nEntrai, buscando a salvação! \nSereis aqui bem-vindos!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aberta! Sim! De par em par! \nEntrai com grande urgência! \nDeus aos constantes vai mostrar \nReal munificência.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deposta a cruz, o vencedor, \nNos Céus entronizado, \nRepousará com o Senhor, \nSeu Deus e Rei amado.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/221-a-porta-da-salvacao/',
      ),
      Hino(
        codigo: 290,
        titulo: 'EIS OS MILHÕES',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis os milhões, que, em trevas tão medonhas, \nJazem perdidos, sem o Salvador! \nQuem lhes irá as novas proclamando, \nQue Deus, em Cristo, salva o pecador?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            '“Todo poder o Pai me deu, \nNa terra, como lá no céu! \nIde, pois, anunciar o evangelho, \nE eis-me convosco sempre”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Portas abertas eis por todo o mundo! \nServos, erguei-vos, eia avante andai! \nCrentes em Cristo, uni as vossas forças, \nDa escravidão os povos libertai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Oh! Vinde a Mim!”, a voz divina clama, \n“Vinde!” clamai em nome de Jesus! \nQue pra salvar-nos do castigo eterno, \nSeu sangue derramou por nós na cruz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Deus, apressa o dia tão glorioso, \nEm que os remidos todos se unirão \nNum coro excelso, santo, jubiloso; \nPra todo sempre glória a Ti darão!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/eis-os-milhoes/',
      ),
      Hino(
        codigo: 291,
        titulo: 'LEVA TU CONTIGO O NOME',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Leva tu contigo o nome de Jesus, o Salvador; \nEste nome dá conforto sempre, seja onde for.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Nome bom, doce à fé, \nA esperança do porvir               (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Este nome leva sempre para bem te defender \nEle é a arma ao teu alcance, quando o mal te aparecer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh, que nome precioso! Gozo traz ao coração; \nSendo por Jesus aceito, tu terás o seu perdão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santo nome, adorável, tem Jesus, o amado teu, \n“Rei dos reis, Senhor eterno” tu O aclamarás no Céu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/62-nome-precioso/',
      ),
      Hino(
        codigo: 292,
        titulo: 'O SOM DO EVANGELHO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O som do Evangelho \nJá se fez ouvir aqui; \nBoas novas e alegres \nElas são pra ti e mim \n“Assim Deus nos amou, \nAos pobres pecadores, \nQue dos Céus seu Filho deu-nos, \nPra sofrer as nossas dores”.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Santa paz! E perdão! \nÉ o eco lá dos céus! \nSanta paz! E perdão! \nBendito o nosso Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A voz do Evangelho \nDá-nos todos a saber \nPois fartura há para todos \nSim, pra quem com fé comer \n“O pão da vida sou; \nSatisfeito ficarás; \nTeus pecados e tua alma \nLavarei, e paz terás”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A voz do Evangelho \nOra vem-nos avisar \nDo perigo grande e grave \nPara quem se descuidar; \n“Salvai-nos desde já; \nNão vos demoreis aí \nNão vireis pra trás os olhos, \nO perigo jaz aí”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A voz do Evangelho \nJubiloso som que é! \nO amor de Jesus Cristo \nDá perdão mediante a fé \n“As novas se vos dão \nDe haver um salvador, \nPoderoso e bondoso, \nQue perdoa ao pecador”.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-aleluia/o-som-do-evangelho/',
      ),
      Hino(
        codigo: 293,
        titulo: 'O EVANGELHO DA SALVAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ouves, como o Evangelho \nNos dá Vera salvação, \nE transforma o homem velho \nNuma nova criação? \nBem algum em mim não via, \nMas somente corrupção, \nE cansado da porfia \nEm Jesus achei perdão. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como a pomba que cansada \nFoi na arca repousar, \nA minh\'alma fatigada \nEm Jesus vai descansar; \nMas o corvo foi s\'embora, \nSobre os mortos foi pousar, \nIsto fazes tu agora? \nQuererás ao mal voltar?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É Jesus a minha arca \nOnde posso repousar, \nE dali, do mal as marcas, \nNem eu posso avistar! \nO quão doce a chamada \nQue a mim me fez Jesus! \n“Vem, ó alma tão cansada, \nVem das trevas para luz”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pecador que estás ouvindo \nA mensagem do Senhor, \nTu na arca és bem-vindo, \nNo refúgio de amor, \nPois as águas do pecado \nBreve te alcançarão, \nPela morte despertado, \nBaterás na porta em vão!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-evangelho-da-salvacao/cifra.html',
      ),
      Hino(
        codigo: 294,
        titulo: 'O NOVO NASCIMENTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um rico, de noite, chegou a Jesus, \nA fim de saber o caminho da luz; \nO Mestre bem claro lhe fez entender;',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Importa renascer! \nImporta renascer! \nCom voz infalível o disse Jesus: \nImporta renascer!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vós, filhos do mundo, escutai ao Senhor, \nQue sempre vos chama com mui terno amor; \nOuvi que o Senhor nunca cessa em dizer: \nImporta renascer!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó vós, que no santo descanso de Deus \nQuereis ter entrada, e viver com os seus, \nDeveis a palavra de Cristo aprender: \nImporta renascer!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se amados no céu desejais encontrar, \nDeveis vossas culpas a Deus confessar \nE a ordem de Cristo com fé acolher: \nImporta renascer!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/o-novo-nascimento/',
      ),
      Hino(
        codigo: 295,
        titulo: 'PESCADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus conserta minha rede \nQue eu quero ser um pescador \nPescador que não apanha peixes \nNecessita do Senhor                    (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há peixes que escapam da rede \nPor um cordão que arrebentou \nConsertemos, irmãos, nossas redes \nNa presença do Senhor                (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ficaram maravilhados \nCom os peixes que Pedro apanhou \nFoi porque Pedro lançou as redes \nNa presença do Senhor                (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu podes ser moço ser velho \nTu podes até ser doutor \nMas Jesus está te chamando \nÉ para ser um pescador                (Bis)',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 296,
        titulo: 'PRECISAMOS DE JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando o sol brilhar em qualquer lugar, \nTu precisas de Jesus; \nQuando escurecer, tudo fenecer, \nTu precisas de Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu preciso de Jesus, \nTu precisas de Jesus; \nPecador, vem para a luz \nQue resplandeceu na cruz; \nTu precisas de Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'P\'ra obter perdão, plena salvação, \nTu precisas de Jesus! \nPara caminhar firme, sem errar; \nTu precisas de Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mesmo havendo paz, calma mui veraz, \nTu precisas de Jesus; \nNa perseguição, na tribulação, \nTu precisas de Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando a morte entrar em teu próprio lar, \nTu precisas de Jesus; \nAnte o Tribunal, decisão final, \nTu precisas de Jesus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/precisamos-de-jesus/',
      ),
      Hino(
        codigo: 297,
        titulo: 'SE NO MUNDO TE SENTES CANSADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se no mundo te sentes cansado \nEnfadado também de viver. \nSe alegria não tens em tua alma, \nConfessa que sempre Jesus tem poder. \nEle chama e socorre o aflito \nQue esperança no mundo não tem. \nEle quer  te salvar, meu amigo, \nEvitar o perigo, por que tu não crês?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Grande amor Deus por ti revelou \nEm Jesus que  tuas culpas pagou. \nQuantas vezes foi Ele humilhado, \nNão sendo culpado, pois nunca pecou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se no mundo o cristão vai chorando \nTropeçando com o peso da cruz, \nSe com fé persistir caminhando \nTerá pela frente um caminho de luz \nEis a grande esperança do crente \nE de quantos confiam em Deus! \nJesus Cristo é o amigo excelente \nQue salva, perdoa e conduz para o céu.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 298,
        titulo: 'TUA ALMA ESTÁ FERIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tua alma está ferida, magoado o coração, \nA tristeza já se apoderou de ti? \nEscuta, meu amigo, Jesus nos fala assim: \n“Ó cansados e oprimidos, vinde à Mim”.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tomai sobre vós o meu jugo, eu vos aliviarei \nE descanso vossas almas gozarão. \nPois o meu fardo é leve, meu jugo é suave, \nPaz perfeita vós tereis no coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desperta tu que dormes, a fé traz esperança, \nJá desponta um novo dia em teu favor \nLembra que Deus é amor, \nJesus nos fala assim: \n“Ó cansados e oprimidos, vinde à Mim”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se creres, meu amigo, terás a salvação, \nPlena paz inundará teu coração; \nEscuta a voz de Cristo, \nJesus nos fala assim: \n“Ó cansados e oprimidos, vinde à Mim”.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 299,
        titulo: 'TRABALHADORES DO EVANGELHO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Trabalhadores do Evangelho, \nEm breve ceifareis; \nQuer fracos vós sejais, ou velhos, \nDo Céu vigor tereis.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Os que esperam no Senhor \nNovas forças obterão \nComo águias voarão, \nSubirão para as alturas; \nCorrerão sem se cansar, \nSem fatigar hão de andar; \nCorrerão sem se cansar, \nSem fatigar hão de andar \nCorrerão sem se cansar \nAté no Céu chegar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No bom trabalho, quantas vezes, \nEstamos a falhar, \nSempre devemos nos revezes \nEm Cristo confiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus está ao nosso lado, \nSua força nos dará \nO nosso Salvador amado, \nSim, tudo suprirá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Cristo sempre confiando \nSocorro vamos ter \nÓ Salvador do Céu baixando \nVirá nos socorrer!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/trabalhadores-do-evangelho/',
      ),
      Hino(
        codigo: 300,
        titulo: 'VEM, VEM A MIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pecador escuta a voz do Senhor: \n“Se estás cansado, ó vem descansar \nVem, não te detenhas; sem nenhum temor, \nDeixa o teu fardo e vem repousar”.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem, vem a mim e descansarás; \nToma o meu jugo e te guiarei; \nSou humilde e manso, dou-te minha paz; \nÓ vem, hoje mesmo, e te salvarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem a Deus, faminto, pobre mesmo assim; \nHá maná celeste, preparado já; \nGrátis é a festa, p\'ra ti e p\'ra mim \nCristo te convida, vem e ceiarás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Andas desviado, longe do redil? \nDeixa de vagar e vem ao bom Pastor; \nPelos montes, vales, há perigos mil? \nVolta ao rebanho do teu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crendo tu, em Cristo, salvação terás; \nGozo, paz perfeita, tudo que é mister; \nCristo não despreza, nem rejeitará \nTodo o que contigo a Ele vier.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vem-vem-mim/completa.html',
      ),
      Hino(
        codigo: 301,
        titulo: 'O SENHOR SALVA A TODO PECADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aleluia! O Senhor salva a todo pecador! \nSalvação! Salvação! \nJesus Cristo tem poder para todo o mal vencer, \nSalvação! Salvação!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Salvação e redenção! \nAleluia! Cristo já me amou e me salvou. \nGlória dou e aleluia, \nA Jesus que me salvou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu confio em Jeová, Ele santidade dá; \nSalvação! Salvação! \nTenho paz e vivo já, sua graça em mim está. \nSalvação! Salvação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Falarei sempre o que sei, exaltando o meu Rei, \nSalvação! Salvação! \nPois Seu sangue já verteu, p\'ra tornar-me filho Seu, \nSalvação! Salvação!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cantaremos, sempre ali, ao sairmos nós daqui; \nSalvação! Salvação! \nExaltando o Salvador, louvaremos com fervor. \nSalvação! Salvação!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/o-senhor-salva-todo-pecador/ghtgtw.html',
      ),
      Hino(
        codigo: 302,
        titulo: 'AS SANTAS ESCRITURAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'São as Santas Escrituras \nQue nos contam de Jesus, \nO qual vindo das alturas \nFez brilhar nas trevas luz! \nP\'ra nos dar eterna vida, \n\'Té a morte se humilhou; \nTendo já vencido a lida, \nDeus, o Pai, o exaltou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Nunca mais vai ser ouvido \nOutro conto de amor, \nQue converta um perdido, \nE rebelde pecador, \nComo o santo Evangelho, \nQue nos fala de perdão, \nE transforma o homem velho \nNuma nova criação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sobre a cruz foi derramado \nO Seu Sangue remidor; \nDuma lança traspassado \nFoi ao lado do Senhor; \nSuas mãos e pés pregaram \nCom uns cravos, sobre a cruz; \nTudo isto me contaram \nDa bondade de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero continuar ouvindo \nA história do Senhor; \nSalvação estou fruindo \nDeste conto de amor! \nDo juízo foi liberto, \nDa condenação, da dor, \nPela Bíblia estou bem certo, \nQue Jesus é o Salvador',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/322-as-santas-escrituras/',
      ),
      Hino(
        codigo: 303,
        titulo: 'A PALAVRA DE DEUS É UM TESOURO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Palavra de Deus é para mim \nUm tesouro sem igual em valor! \nFala do amor de Deus, do amor que não tem fim; \nMais precioso do que ouro é este amor!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A Palavra de Deus é doce, mais que o mel, \nO que toma pela fé há de ser fiel, \nPorque Deus nos concedeu o Emanuel, \nRocha viva donde emana leite e mel.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Luz que guia pela senda da paz, \nE alumia os que em trevas estão; \nLâmpada que nos faz ver os ardis de Satanás, \nE que brilha mesmo na escuridão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É um farol que sempre resplandeceu, \nE que mostra o porto da salvação; \nQuem na arca já entrou e no mundo se esqueceu, \nChegará por certo à eternal mansão.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 304,
        titulo: 'A SANTA BÍBLIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santa Bíblia, para mim, \nÉs o meu tesouro, sim; \nTu conténs a lei de Deus \nE me mostras lindos Céus; \nTu me dizes quem eu sou, \nDonde vim; p\'ra onde vou! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu repreendes meu falar, \nMe exortas sem cessar. \nAlumias os meus pés, \nE me guias, pela fé, \nPara as fontes de amor, \nDo bendito Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'És a voz dos altos Céus, \nDo Espírito de Deus. \nQue vigor p\'ra alma dá, \nQuando em aflição está; \nMe ensinas triunfar \nDentre os mortos, do pecar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por Tua santa letra sei, \nQue com Cristo reinarei; \nEu que tão indigno sou, \nPor Tua luz, ao Céu eu vou; \nSanta Bíblia para mim, \nÉs o meu tesouro, sim!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-santa-biblia/',
      ),
      Hino(
        codigo: 305,
        titulo: 'O PÃO DA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Enquanto, ó Salvador, teu livro eu ler, \nMeus olhos vem abrir, pois quero ver \nDa mera letra, além, a Ti, Senhor; \nEu venho a Ti, Jesus, meu Redentor. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'À beira-mar, Jesus, partiste o pão, \nSatisfazendo ali a multidão; \nDa vida o pão és Tu; vem, pois, assim, \nSatisfazer, Senhor, a mim, a mim!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/137-o-pao-da-vida/',
      ),
      Hino(
        codigo: 306,
        titulo: 'A ALMA ABATIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se tu, minh\'alma, a Deus suplicas, \nE não recebes, confiando fica \nEm Suas promessas, que são mui ricas, \nE infalíveis p\'ra te valer.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Por que te abates, ó minha alma? \nE te comoves, perdendo a calma? \nNão tenhas medo, em Deus espera, \nPorque bem cedo, Jesus virá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ele intercede por ti, minh\'alma; \nEspera nEle, com fé e calma; \nJesus de todos teus males salva \nE te abençoa, dos altos céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Terás em breve, as dores findas, \nNo dia alegre da Sua vinda; \nSe Cristo tarda, espera ainda \nMais um pouquinho, e O verás',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-alma-abatida/simplificada.html',
      ),
      Hino(
        codigo: 307,
        titulo: 'ALGEMADO POR UM PESO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Algemado por um peso \nOh! Quão triste eu andei, \nTé sentir a mão de Cristo, \nNão sou mais como era eu sei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tocou-me, Jesus tocou-me, \nDe paz Ele encheu meu coração! \nQuando, o Senhor, Jesus me tocou, \nLivrou-me da escuridão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desde que encontrei a Cristo, \nE senti seu terno amor; \nTenho achado paz, e vida! \nPra sempre cantarei em sue louvor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/icr/algemado-por-um-peso-tocou-me/',
      ),
      Hino(
        codigo: 308,
        titulo: 'A VIDA NO MUNDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vida no mundo é cruel \nTormentas e lutas sem fim \nCaminho almejando o céu \nJesus tu te lembras de mim.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus tu te lembras de mim \nJesus tu te lembras de mim \nNa vida na morte e na dor \nJesus tu te lembras de mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus o que eu hei de fazer \nSe o mundo está contra mim \nEnvia-me o teu poder \nJesus tu te lembras de mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Navegando vai minha nau \nNo mar desta vida aqui \nAbriga-me no temporal \nJesus tu te lembras de mim.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 309,
        titulo: 'BRILHO CELESTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Peregrinando vou pelos montes \nE pelos vales, sempre na luz! \nCristo promete nunca deixar-me; \n“Eis-me convosco”, disse Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Brilho celeste! Brilho celeste! \nEnche a minha alma da glória de Deus! \nCom aleluias sigo cantando, \nCanto louvores, indo pra os céus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em uma roda, nuvens em cima \nO Salvador não hão de ocultar; \nEle é a luz que nunca se apaga, \nJunto a seu lado sempre hei de andar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vão me guiando raios benditos, \nQue me conduzem para a mansão; \nMais e mais perto, o Mestre seguindo, \nCanto os louvores da salvação.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/brilho-celeste/',
      ),
      Hino(
        codigo: 310,
        titulo: 'A SEMENTE NO FRESCOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cai a semente no frescor, \nCai na força do calor, \nCai na doce viração, \nCai na triste escuridão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Qual será a colheita além, \nA colheita além? \nSempre lançada, com força ou langor, \nCom ousadia, ou com medo e tremor! \nJá, ou nas eras do porvir, \nCerta a colheita, a colheita tem de vir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sobre os rochedos tende a murchar, \nOu nas estradas desperdiçar, \nEntre os espinhos vai-se perder, \nOu nas campinas há de crescer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há sementeira de amargor \nHá de remorsos e negro horror, \nHá de vergonha e confusão \nHá de miséria e perdição.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Anda com pranto o semeador, \nChora os estorvos no seu labor; \nOu jubiloso, com festim, \nNutre esperança de nobre fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vale-me, grande Semeador! \nDá-me a semente do teu labor! \nQuero servir-Te meu Rei Jesus, \nQuero ceifar contigo em luz!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 311,
        titulo: 'CRISTO VALERÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oscilando minha fé, \nCristo valerá; \nPerseguindo, sem mercê, \nEle valerá.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ele valerá! Ele valerá! \nSeu amor por mim não muda, \nSim, me valerá.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crente inútil eu serei \nSe me não valer; \nNem serviço prestarei \nSem o seu poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com seu sangue me comprou, \nNão me deixará; \nVida eterna me outorgou, \nSim, me valerá.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/cantor-cristao-322-cristo-valera/',
      ),
      Hino(
        codigo: 312,
        titulo: 'DESCANSA, Ó ALMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Descansa, ó alma; eis o Senhor ao lado; \nPaciente leva, e sem queixar-te, a cruz. \nDeixa o Senhor tornar de ti cuidado: \nEle não muda, o teu fiel Jesus! \nProssegue, ó alma: o Amigo Celestial \nProtegerá teus passos no espinhal! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Prossegue, ó alma; o trilho é estreito e escuro; \nMas no passado Deus guiou-te assim! \nConfia agora a Deus o teu futuro, \nQue esse mistério há de aclarar-se enfim. \nConfia, ó alma: a sua mansa voz \nAinda acalma o vento e o mar feroz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Confia ó alma: a hora vem chegando, \nIrás com Cristo, o teu Senhor, morar. \nSem dor nem mágoas gozarás, cantando, \nAs alegrias do celeste lar; \nDescansa, ó alma; agora há pranto e há dor, \nDepois, o gozo, a paz, o Céu e amor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-presbiteriano-novo-cantico/hino-156-confianca-em-deus/',
      ),
      Hino(
        codigo: 313,
        titulo: 'FICA CONOSCO SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Veloz o dia declina \nA noite já se aproxima, \nÓ luz celeste e divina \nRogamos tua presença. \nEm Ti, Jesus, nossas almas \nSaudaram o Mestre amado, \nContigo as noites são calmas \nFica conosco, Senhor           (bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Debaixo dos teus olhares, \nÉ santa a tua alegria \nSão doces mesmos os pesares, \nPerto do teu coração. \nSol no caminho da vida, \nAlento no desespero \nBálsamo para alma ferida \nÉs meu divino, Jesus            (bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando, no fim da jornada, \nFormos para a eternidade, \nGuia-nos nesta passagem \nFica conosco, Senhor. \nÓ Tu meu terno amor forte \nTão firme como a esperança, \nMais invencível que a morte. \nFica conosco Senhor!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 314,
        titulo: 'GUIA-ME SEMPRE, MEU SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aonde guiar-me meu Senhor, \nEu seguirei, por Seu amor; \nÉ Sua mão que me conduz, \nPor mim ferida sobre a cruz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Guia-me sempre, meu Senhor, \nGuia meus passos, Salvador; \nTu me compraste sobre a cruz; \nRege-me em tudo, meu Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Acho prazer em Te seguir; \nDescanso e paz me faz sentir; \nDoce  é a mim o Teu querer, \nGozo me traz Te obedecer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sigo sem medo o meu Senhor \nQue me encheu do Seu amor; \nSentindo perto a Sua mão, \nPosso cantar na escuridão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para Seu reino me conduz, \nPelo jardim e pela cruz; \nLá ficou morto o velho “eu”, \nLá meu espírito reviveu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/guia-me-sempre-meu-senhor/',
      ),
      Hino(
        codigo: 315,
        titulo: 'ISRAEL SAIU DO EGITO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Israel saiu do Egito, \nFoi ordem que Deus lhe deu, \nChegando ao Mar Vermelho \nTodo Israel temeu. \nMontes altos de todos os lados \nMoisés lhe respondeu: \nNão temas, ó Israel, \nSó o Senhor é Deus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Só o Senhor é Deus, \nCantemos com muita alegria    (Bis) \nDizendo que só o Senhor é Deus',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Moisés ordenou às águas \nDo mar, que lhe obedeceu \nPor terra seca passou \nPelo poder de Deus \nO exército de Faraó \nPorém, no mar pereceu. \nMiriã cantou dizendo: \nSó o Senhor é Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No deserto faltou água, \nIsrael se entristeceu; \nTodos se revoltaram \nContra o Servo de Deus \nMoisés fez uma oração, \nJeová lhe respondeu! \nMiriã cantou dizendo: \nSó o Senhor é Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os profetas de Baal, \nEm holocausto seus, \nClamaram até ao meio dia, \nBaal não lhes respondeu, \nElias fez a oração, \nO fogo do céu desceu \nQueimando todo o holocausto \nPelo poder de Deus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/so-o-senhor-e-deus-5/',
      ),
      Hino(
        codigo: 316,
        titulo: 'NÃO SE PODE MATAR UM CRENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não se pode matar um crente \nQuem é salvo não morrer não \nEle sobe à presença de Deus \nPrá receber o seu galardão \nRoupas alvas, tão lindas, tão puras \nEles trocam pra vida melhor \nDeixam tudo por amor a Cristo, \nPra viver em um mundo melhor',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não, não se pode matar um crente, \nJesus não mente, falou assim: \n“Quem perde a vida por mim não morre \nPorque sua morte não é o fim”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu irmão, tu estás temendo \nDe quem pode tua vida ceifar. \nSaiba que o inimigo maior \nÉ aquele que pode tua alma tragar, \nNão te cales, não temas o mundo \nVai buscando de Deus o Poder. \nE verás que na hora da morte \nO Senhor não te deixa morrer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os romanos se divertiam \nVendo as feras matando os cristãos, \nNão sabiam que, naquela arena, \nGotas de sangue eram os grãos. \nQue brotaram e se espalharam \nRecebendo de Deus o poder, \nPra mostrar aos reis deste mundo \nQue o crente não pode morrer.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cecilia-de-souza/nao-se-pode-matar-uma-crente/',
      ),
      Hino(
        codigo: 317,
        titulo: 'NÃO CONSINTAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Não consintas as tristezas \nDentro do teu coração; \nTendo fé firme no Mestre, \nSegue-O sem hesitação.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Não consentir! Não consentir \nQue qualquer dor ou tristeza \nVenha apagar teu amor! \nOh! Não temer! Nunca ceder! \nEm teus apertos te lembra \nQue Cristo é teu Protetor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se por acaso desgostos \nVierem trazer-te temor, \nNunca te esqueças de Cristo, \nQue é teu maior Protetor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deixa, pois, tua tristeza, \nToda incerteza e temor; \nPaz e prazer tu em breve \nReceberás do Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/339-nao-consintas/',
      ),
      Hino(
        codigo: 318,
        titulo: 'SOSSEGAI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Mestre, o mar se revolta, \nAs ondas nos dão pavor; \nO céu se reveste de trevas, \nNão temos um salvador! \nNão se te dá que morramos? \nPodes assim dormir, \nSe a cada momento nos vermos, \nSim, prestes a submergir?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'As ondas atendem ao seu mandar: \nSossegai! Sossegai! \nSeja o encapelado mar, \nA ira dos homens, o gênio do mal, \nTais águas não podem a nau tragar, \nQue leva o Senhor, Rei do Céu e mar, \nPois todos ouvem o meu mandar: \nSossegai! Sossegai! \nConvosco estou para vos salvar; \nSim, sossegai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mestre, na minha tristeza \nEstou quase a sucumbir; \nA dor que perturba minh\'alma, \nEu peço-te, vem banir! \nDe ondas do mal que me encobrem, \nQuem me fará sair? \nPereço sem ti, ó meu Mestre! \nVem logo, vem me acudir!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mestre, chegou a bonança, \nEm paz eis o céu e o mar! \nO meu coração goza calma, \nQue não poderá findar. \nFica comigo, ó meu Mestre. \nDono da terra e céu, \nE assim chegarei bem seguro \nAo porto, destino meu.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/578-sossegai/',
      ),
      Hino(
        codigo: 319,
        titulo: 'SUBO O MORRO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Levarei a minha cruz cantando \nJesus Cristo vem me ajudar. \nAo chegar ao fim desta jornada \nPara sempre eu vou descansar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Subo o morro e desço o morro \nCarregando a minha cruz           (Bis)\nMas não canso de marchar \nAo encontro de Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando subo um morro muito alto \nMinha cruz começa a escorregar \nEu canto um hino de louvor \nJesus Cristo vem me ajudar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando eu vou atravessar o mar \nE as ondas tentam me cercar \nEu cantando falo com Jesus \nTira as ondas para eu passar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ou com fome, ou com sede eu vou \nCarregando a minha cruz pesada. \nPara receber minha coroa \nQue no céu está preparada.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 320,
        titulo: 'SOBRE AS ONDAS DO MAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Por que duvidar, \nSobre as ondas do mar, \nQuando Cristo caminho abriu? \n- Quando forçado és, contra as ondas lutar, \nSeu amor a ti quer revelar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Solta o cabo da nau \nToma os remos na mão, \nE navega com fé em Jesus; \nE então tu verás que bonança se faz \nPois com Ele, seguro serás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Trevas vêm te assustar \nTempestades no mar? \nDa montanha o Mestre te vê; \nE na tribulação Ele vem socorrer, \nSua mão bem te pode suster.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Podes tu recordar, \nMaravilhas, sem par? \nNo deserto ao povo fartou; \nE o mesmo poder Ele sempre terá, \nPois não muda e não falhará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando pedes mais fé, \nEle ouve, ó crê! \nMesmo sendo em tribulação; \nQuando a mão de poder o teu “ego” tirar, \nSobre as ondas poderás andar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/467-sobre-as-ondas-do-mar/',
      ),
      Hino(
        codigo: 321,
        titulo: 'UM POBRE CEGO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um pobre cego à beira de uma estrada, \nEnvolto em trapos, trevas e desdém, \nPedia esmola de alma angustiada, \nVeio Jesus e trouxe a luz e o bem.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ao vir Jesus, a tempestade cessa, \nAo vir Jesus, as lágrimas se vão; \nEle transforma toda a nossa vida, \nIluminando a negra escuridão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hoje também o pecador depara, \nEm Cristo livramento de aflição, \nEm meio a tentação que o destroçara, \nVeio Jesus e trouxe a salvação.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 322,
        titulo: 'VOU ANDANDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vou andando, caminhando \nSempre alegre a cantar \nPois o fogo do espírito \nArde em meu coração \nVou andando, caminhando \nMeu barquinho é o melhor \nPois Jesus está comigo \nMeu piloto, meu abrigo \nQuando o temporal chegar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vou andando, caminhando \nVou andando, caminhando          (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Muitas vezes as tristezas \nQuerem me desanimar \nOs meus pés estão feridos \nQuase prestes a sangrar \nMesmo em lutas ou em sombras \nCom Jesus eu quero andar, \nPois Jesus está comigo \nEle é meu grande amigo \nE com Ele eu vou andar.                   (Bis)',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 323,
        titulo: 'GRAÇAS DOU POR ESTA VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Graças dou por esta vida \nPelo bem que revelou. \nGraças dou pelo futuro \nE por tudo que passou \nPelas bênçãos derramadas. \nPelo amor e a aflição \nPelas graças reveladas \nGraças dou pelo perdão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Graças pelo azul celeste \nE por nuvens que há também \nPelas rosas do caminho \nE os espinhos que elas têm. \nPela escuridão da noite, \nE a estrela que brilhou \nPela prece respondida \nE a esperança que falhou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pela cruz e o sofrimento \nE pela ressurreição. \nPelo amor que é sem medida \nE a paz no coração, \nPela lágrima vertida \nE o consolo que é sem par \nPelo Dom da eterna vida, \nSempre graças hei de dar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/gracas-dou/original.html',
      ),
      Hino(
        codigo: 324,
        titulo: 'UM ANO MAIS DE VIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um ano mais de vida \nGuardou-vos o Senhor, \nE deu-vos fiel guarida \nNo seu divino amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'De coração daí graças \nAo vosso eterno Pai! \nPois mais um ano passa, \nA Deus mil graças dai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De noite e em claro dia, \nNo inverno e no verão, \nNa dor e na alegria, \nGozaste proteção,',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No coração que sente \nAs bênçãos do Senhor \nUm canto alegre e ardente \nEspalha o seu amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-presbiteriano-novo-cantico/gracas-pelo-aniversario-hino-396/',
      ),
      Hino(
        codigo: 325,
        titulo: 'MÃE QUERIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minha mãe querida e boa \nTu tiveste amor por mim \nO seu nome assim perdura \nPelos séculos sem fim \nSacrifícios desdobrados \nQue por este filho deu \nTu tiveste mil cuidados \nPois seu coração sofreu. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando o céu se escurecia \nVindo a noite e a escuridão \nMinha mãe me recolhia \nE cantava esta canção \nDorme, dorme meu filhinho \nDorme, dorme coração. \nDorme, dorme bem cedinho \nFaça a Deus uma oração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para a escola me guiava \nQuando ainda pequenino \nCede, cedo me educava \nPara ser um bom menino \nNa escola eu aprendia \nAos domingos a lição \nEu cantava e a Deus dizia: \n“Eu te dou o meu coração”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Para longe bem distante, \nMinha boa mãe partiu \nMe deixou no mundo errante \nE de luto me encobriu \nMas na glória dos remidos \nHei de vê-la junto a Deus \nPara sempre, sempre unidos \nViveremos lá nos céus.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 326,
        titulo: 'AVANTE, MOCIDADE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mocidade cristã, eia, avante! \nVossas forças uni pra lutar! \nO inimigo potente se mostra, \nMas com Cristo sois fortes: Marchai!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Mocidade cristã, eia, avante! \nContra o mal, contra o erro lutai! \nTendo o santo evangelho por arma, \nA verdade da cruz proclamai!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mocidade cristã, vede o abismo, \nOnde muitos estão a cair! \nPor faltar-lhes a luz do evangelho, \nNão procuram a Cristo seguir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eia, jovens, ativos obreiros, \nPela causa do bem pelejai! \nIde aos povos levar o evangelho, \nPara a glória de Deus batalhai',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 327,
        titulo: 'AVANTE! AVANTE! Ó CRENTES',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Avante, avante, ó crentes! \nSoldados de Jesus! \nErguei seu estandarte, \nLutai por sua cruz! \nContra hostes inimigas, \nAnte essas multidões, \nO comandante excelso \nDirige os batalhões. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Avante, avante, ó crentes! \nPor Cristo pelejai! \nVesti sua armadura \nEm seu poder marchai! \nNo posto sempre achados, \nVelando em oração: \nPor meio de perigos \nSeguindo o Capitão!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Avante, avante, ó crentes! \nCom passo triunfal! \nHoje há combate horrendo! \nMui cedo a paz final! \nEntão eternamente \nBendito o vencedor, \nPor Deus vitoriado \nCom Cristo, o Salvador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/igreja-metodista-hinario-evangelico/401-avante--crentes/',
      ),
      Hino(
        codigo: 328,
        titulo: 'AS ALMAS CUSTAM LÁGRIMAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos lutar, em favor das almas \nPara acalmar o mundo \nQue está sem calma \nAmando uns aos outros \nComo Cristo ensinou \nAs almas custam lágrimas \nAté Jesus chorou              (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sei que as vezes nos cercam os perigos. \nTirando as almas, \nDas garras do inimigo \nSendo perseguidos, \nMas sempre vencedores \nAs almas custam lágrimas \nAté Jesus chorou               (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vida do salvo \nÉ uma carta aberta \nCom o seu testemunho, \nAs almas se despertam, \nAnunciando o bom Salvador, \nAs almas custam lágrimas \nAté Jesus chorou               (Bis)',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 329,
        titulo: 'ALERTA, JOVENS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vinde, ó mocidade, \nDedicar com todo o amor, \nSim, com ansiedade, \nVossa vida ao Salvador. \nEles vos convida \nPara virdes trabalhar; \nNessa santa lida \nVinde com prazer entrar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Trabalhar, com todo ardor \nVinde vós, ó moços,              (Bis) \nPor Jesus, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Contemplai as almas \nLonge do Senhor Jesus; \nComo vivem calmas \nSem saber do amor da cruz! \nAndam enganadas, \nSem pensar no triste fim; \nSem Jesus, coitadas, \nÉ um triste estado, sim!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Levai a nova \nQue Jesus lhes dá perdão! \nIde dar a prova \nDesse amor da salvação! \nVede como as gentes, \nAfastadas do bom Deus, \nTodas descontentes, \nClamam pela luz dos céus.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 330,
        titulo: 'CAMPEÕES DA PELEJA SAGRADA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Campeões da Peleja Sagrada! \nO clarim chama à luta os fiéis! \nVamos nós nesta arena bendita \nConquistar os viçosos lauréis!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vamos já com Jesus, vamos com Jesus, \nArvorando o brilhante pendão! \nContra as trevas lutemos; Avante, pois, \nFirmes, crentes no bom Capitão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sim! A luta do bem é Suprema: \nÉ preceito e conselho de Deus; \nE por isso a vitória é segura, \nPois tem bênçãos e ajuda dos Céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se o labor desta causa altaneira \nTem espinhos, que podem ferir, \nCompensado no Céu é mil vezes, \nPor nos dar o mais grato porvir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E se o mundo atear os seus ódios \nContra nós, com mordente desdém, \nNão importa! Jamais entibia \nOs heróis da conquista do bem.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 331,
        titulo: 'MEU BRASIL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu Brasil, grande nação, Pátria sublime, \nQuero ver-te muito breve inda maior, \nCombatendo a iniquidade, o vício, o crime, \nRedimido aos pés de Cristo, o Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Meu Brasil! Meu Brasil! \nAbre o largo seio e deixa a luz raiar, \nMeu Brasil! Meu Brasil! \nO evangelho de Jesus te quer salvar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não te peço, meu Senhor, poder, riqueza, \nNem os faustos deste mundo de ilusão, \nDar que eu possa ver fulgindo de beleza, \nNa coroa de Jesus, minha nação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Debelar a escuridão minh\'alma anseia, \nDesta terra onde o cruzeiro prega a paz; \nEspalhemos livros, Bíblias à mão cheia, \nE a vitória, meu Brasil, alcançará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando o Oriente estava em densas trevas, \nA estrela de Jacó se viu brilhar; \nE os magos vieram de suas terras \nVer Jesus que meu Brasil veio salvar.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/daniel-regis/meu-brasil/',
      ),
      Hino(
        codigo: 332,
        titulo: 'CEIFANDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Espalhemos todos a semente santa, \nDesde a madrugada até o anoitecer, \nCalmos, aguardando o tempo da colheita, \nQuando alegremente havemos de colher.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Havemos de colher! Havemos de colher! \nOh! Quão jubiloso havemos de colher! \nHavemos de colher! Havemos de colher! \nMesses abundantes havemos de trazer!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Semeemos quando seres perniciosos \nA semente boa querem destruir; \nDeus abençoando, alegres, satisfeitos, \nA colheita santa havemos de fruir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eia, pois, obreiros, semeai, ousados, \nA semente viva da verdade e luz, \nProclamando Cristo, seu poder e glória. \nSalvação perfeita que alcançou na cruz!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/429-ceifando/',
      ),
      Hino(
        codigo: 333,
        titulo: 'MEU SALVADOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desceu lá do céu o bom filho de Deus \nPra ser meu e teu Salvador. \nDesprezou as dores para nos resgatar; \nÓ sim, Ele é meu Salvador.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus por Si mesmo se deu \nPra ser Salvador de um qual eu; \nE o fardo cairá de quem turbado está, \nRecorrendo a Jesus que morreu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu tenho o meu lar para ali repousar \nPela súplica do Redentor \nLá no monte a orar foi sozinho ficar; \nÓ sim, Tu és meu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vendido à traição, a sentença lhe dão \nE morto qual vil salteador, \nMas eu vendo a cruz digo logo a Jesus \nÓ sim, Tu és meu Salvador.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 334,
        titulo: 'DESPERTA MOCIDADE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desperta, mocidade, Jesus está a voltar, \nVeja bem onde é que tu estás, \nPelas santas profecias nós já vemos os sinais, \nVeja bem onde é que tu estás.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Lembra do teu Criador, \nNos dias da tua mocidade,                 (Bis) \nAntes que venham os maus dias \nDepois não vais dizer que agora é tarde',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus está chamando os cansados e oprimidos \nVeja bem onde é que tu estás \nEle quer aliviar o teu grande sofrimento \nVeja bem onde é que tu estás.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 335,
        titulo: 'É TEMPO, É TEMPO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É tempo, é tempo, o Mestre está chamando já! \nMarchar, marchar, confiando em seu amor! \nPartir, partir, a salvação a proclamar, \nCom a palavra santa do bom Salvador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Marchar, sim avante! \nMarchar, erguendo o pendão real! Avante! \nSim, avante, unidos, firmes sempre a avançar. \nGlória, glória, eis que canta a multidão! \nConsagrando todo o vosso coração, \nPra Jesus obedecer, seu querer executar, \nEntoai louvores altos! Avançar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            '“Queremos luz”  é o grito das nações pagãs, \nque vêm atravessando o imenso mar. \nIr já, sim já, levando novas de amor, \nSem esquecer também aqui de semear.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desperta, Igreja! O teu poder vem exercer, \nA todos faze Cristo Conhecer; \nA tua mão estende com paciente amor; \nEsforça-te da morte eterna a os deter.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Igreja, alerta! O dia prometido vem, \nQuando aclamado o Salvador será; \nPor toda parte o bem amado Redentor \nEterna glória, honra e louvor será ',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 336,
        titulo: 'É O TEMPO DE SEGAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'É o tempo de segar e tu sem vacilar, \nDeclaraste sem temor: “Não posso trabalhar?” \nVem, enquanto Cristo, o Mestre, está a te chamar: \n“Jovem, jovem, ó vem trabalhar!”',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vem e vê os campos brancos já estão \nAguardando braços que os segarão; \nJovem, desperta, faz-te pronto e alerta. \nQueiras logo responder: “Eis-me aqui, Senhor”. \nOlha que a seara bem madura está; \nQue colheita gloriosa não será! \nJovem, desperta. Faz-te pronto e alerta! \nPoucos dias são que restam para o segador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As gavelas que recolhes: jóias de esplendor \nBrilharão na tua coroa, e darão fulgor; \nBusca logo essas jóias, Deus é premiador; \nJovem, jovem, entra no labor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A manhã já vai passando, não mais voltará; \nDa colheita o tempo brevemente findará; \nE perante o teu senhor vazio t\'acharás; \nJovem, jovem, obedece já.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/e-tempo-de-segar/',
      ),
      Hino(
        codigo: 337,
        titulo: 'FELICIDADE NO SERVIÇO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No serviço do meu rei eu sou feliz, \nSatisfeito, abençoado; \nProclamando do meu Rei  a salvação, \nNo serviço do meu Rei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'No serviço do meu Rei \nMinha vida empregarei; \nGozo, paz, felicidade \nTem quem serve a meu bom Rei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No serviço do meu Rei eu sou feliz, \nObediente e corajoso; \nNa tristeza ou na alegria sei sorrir, \nNo serviço do meu Rei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No serviço do meu Rei eu sou feliz, \nJubiloso e consagrado; \nAo seu lado desafio a todo mal, \nNo serviço do meu rei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No serviço do meu Rei eu sou feliz, \nVenturoso e decidido; \nQuanto tenho no serviço gastarei, \nNo serviço do meu Rei.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/410-felicidade-no-servico/wpppjs.html',
      ),
      Hino(
        codigo: 338,
        titulo: 'IRMÃOS AMADOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmãos amados  E resgatados, \nSegui avante  E triunfantes, \nCombateremos  E venceremos, \nNo Nome santo de Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'No Nome santo  alegre canto: \nEu fui lavado  Santificado; \nVivi perdido  Mas sou remido, \nNo Nome santo de Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmãos amados  Santificados, \nVivei unidos  Pois sois remidos, \nNão mais temendo  O bem fazendo, \nNo nome santo de Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmãos amados  Purificados, \nSede valentes  E mui prudentes, \nEstais lavados  E libertados, \nNo Nome Santo de Jesus',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/irmaos-amados/simplificada.html',
      ),
      Hino(
        codigo: 339,
        titulo: 'AVIVA-NOS SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aviva-nos, Senhor! \nOh! Dá-nos teu poder \nDe santidade, fé e amor \nReveste o nosso ser!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Aviva-nos Senhor, \nEis nossa petição; \nAteia fogo do alto Céu \nEm cada coração!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Desperta-nos, Senhor! \nOh! Faze-nos fruir \nAs ricas bênçãos divinais, \nPrimícias do porvir!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Renova-nos, Senhor, \nInspira mais amor, \nMais zelo, graça e abnegação \nA bem do pecador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-aleluia/aviva-nos-senhor-hino-25/',
      ),
      Hino(
        codigo: 340,
        titulo: 'JUVENTUDE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Levantai-vos, moços crentes, \nPara anunciar Jesus \nComo Salvador do mundo, \nVerdadeiro Guia e Luz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Despertai-vos! Levantai-vos! \nNão há tempo que perder. \nSe quereis servir a Cristo, \nTendes muito que fazer.            (Bis)\nMeditai no seu amor. \nMeditai no que Ele fez; \nPela morte no Calvário \nResgatou-nos de uma vez!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sim, Ele é “a Luz do mundo”! \nEle poderá dizer: \n“Só Eu dou a vida eterna \nA qualquer que queira crer.” ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois se nós estamos certos \nDe que Cristo é Salvador, \nVamos publicá-Lo a todos \nCom coragem e fervor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E se nós, sinceramente, \nJá servimos nosso Deus, \nExultamos, na certeza, \nDe encontra-Lo lá nos céus.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 341,
        titulo: 'JOVENS LUTADORES',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó jovens, acudi ao brilhante pavilhão \nQue Jesus há desfraldado na nação! \nA todos, Cristo quer nas fileiras receber. \nE mui firmes nos levar o mal a combater.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vamos com Jesus e marchemos sem temor! \nVamos ao combate, inflamados de valor! \nCom coragem vamos todos contra o mal! \nEm Jesus teremos nosso General!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó jovens, acudi ao divino Vencedor; \nQuer juntar-vos todos hoje a seu redor! \nDispostos a lutar, vinde, pois, sem vacilar! \nVamos prontos, companheiros, vamos a lutar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem nesta guerra entrar sua voz escutará, \nCristo então vitória lhe concederá! \nSaiamos, meus irmãos, invistamos mui fiéis; \nCom Jesus conquistaremos imortais lauréis!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 342,
        titulo: 'NEM SEMPRE SERÁ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nem sempre será para onde eu quiser \nQue o Mestre me há de mandar. \nÉ grande a seara a embranquecer \nEm que venho a trabalhar. \nSe, pois, há caminhos que nunca segui, \nUma voz a chamar-me eu ouvi, \nDirei: “Meu Senhor, confiado em Ti, \nEstou pronto, onde queres, a ir.”',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Estou pronto a fazer o que queres, Senhor, \nConfiado no Teu poder, \nEstou pronto a dizer o que queres, Senhor, \nEstou pronto o que queres a ser.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há talvez palavras de amor e perdão \nQue aos outros eu possa levar; \nTalvez pela estrada do vício vão \nPerdidos que eu deva ir buscar. \nSenhor, se a tua presença real \nMe acompanha pra fortalecer, \nA mensagem darei, como servo leal; \nEstou pronto o que queres dizer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um canto obscuro eu quero encontrar \nNa seara do meu bom Senhor; \nEnquanto for vivo eu vou trabalhar \nEm prova do meu grande amor, \nDe Ti meu sustento só dependerá, \nTu hás de me proteger; \nA tua vontade a minha será; \nEstou pronto o que queres a ser.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 343,
        titulo: 'OBREIRO SANTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Obreiro santo, Jesus te manda pregar \nO Evangelho e muitas almas ganhar, \nVai levar para os famintos da terra, \nComo soldado na guerra, vai para os campos lutar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Jesus, Jesus me guia nesta jornada \nQuem tem Jesus, tem tudo                  (Bis) \nQuem não tem Jesus, não tem nada',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus disse: Estes sinais seguirão, \nEm meu nome demônios expulsarão. \nVai então com coragem e graça, ó crente! \nE vencerás a serpente, os enfermos curarão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nenhum mal te acontecerá, ó irmão! \nLá no campo serpentes tu pisarás, \nOnde andares hei de te abençoar \nSeja na terra, nos ares, mesmo nas ondas do mar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nunca digas: sou pobre, não tenho nada \nTeu empenho, seja na Bíblia Sagrada, \nNa jornada, queiras sempre andar na Luz. \nQuem tem Jesus tem tudo, \nQuem não tem Jesus não tem nada.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 344,
        titulo: 'O ESTANDARTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O estandarte desta igreja \nLevantemos sem temor! \nEla é muito amada Esposa \nDo bendito Salvador \nÉ Jesus o comandante \nVerdadeiro, que a conduz. \nSomos nós os seus soldados \nNesta igreja de Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Resolutos avançai, \nTrabalhando por Jesus! \nO estandarte levantai, \nEspalhando a sua luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó igreja, dediquemos \nNossos corpos ao Senhor! \nNão devemos ser escravos \nDo sagaz enganador. \nAs riquezas são-nos dadas \nPela terna mão real. \nE o Senhor do céu observe \nSe fazemos bem ou mal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Graça e glória a ti pertencem, \nÓ Esposa do Senhor! \nSê então um instrumento \nDe salvar o pecador; \nPois até os fins do mundo \nCristo mesmo reinará, \nE o domínio do evangelho \nToda a terra abrangerá.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/456-o-estandarte/',
      ),
      Hino(
        codigo: 345,
        titulo: 'OH! ONDE OS OBREIROS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Onde os obreiros pra trabalhar \nNos campos tão vastos a laborar? \nA obra exige esforço e valor. \nOh! Quem quer lavrar com zelo e ardor?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Onde os obreiros? \nOh! Quem quer ir, \nNos campos do Mestre, as faltas suprir? \nOh! Quem está pronto a se entregar? \nE a ceifa bendita aproveitar?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O joio do mal tende a aumentar, \nE o trigo do Mestre quer sufocar; \nCeifeiros, avante, nos campos entrai, \nEnquanto é dia, ceifa\.\.\. ceifai! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis portas abertas pra salvação. \nNações almejando a Redenção; \nOh! Onde os obreiros para anunciar \nDe Deus o perdão, dum amor sem par?',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 346,
        titulo: 'OS GUERREIROS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os guerreiros se preparam para a grande luta \nÉ Jesus o Capitão, que avante os levará. \nA milícia dos remidos marcha impoluta; \nCerta que vitória alcançará!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu quero estar com Cristo, onde a luta se travar \nNo lance imprevisto na frente me encontrar \nAté que O possa ver na glória \nSe alegrando da vitória, onde Deus vai me coroar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis os batalhões de Cristo prosseguindo avante, \nNão os vês com que valor combatem contra o mal? \nPodes tu ficar dormindo, mesmo vacilante, \nQuando atacam outros a Belial?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dá-te pressa, não vaciles, hoje Deus te chama \nPara vires pelejar ao lado do Senhor; \nEntra na batalha onde mais o fogo inflama, \nE peleja contra o vil tentador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A peleja é tremenda, torna-se renhida, \nMas são poucos, os soldados para batalhar; \nÓ vem libertar os pobres almas oprimidas \nDe quem furioso as quer tragar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/os-guerreiros-se-preparam/simplificada.html',
      ),
      Hino(
        codigo: 347,
        titulo: 'PELEJAR POR JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Por Jesus vamos pelejar, \nProsseguindo o nosso andar; \nE com Ele, então, no céu, \nNós iremos a paz gozar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Lutemos todos contra o mal, \nE vamos a Jesus seguir; \nEle é o nosso General \nE a glória do porvir!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em Jesus temos nós poder; \nAvancemos, já sem temer; \nConfiando no Seu amor, \nVamos lutar, até vencer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Crentes, para Jesus olhai, \nPela fé, sempre, sim, lutai; \nAo inimigo, ó combatei; \nO Evangelho anunciai.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Escritura nos diz assim: \nQue Jesus é p\'ra ti e mim, \nO Caminho, a Luz veraz, \nQue nos leva ao céu, enfim.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/108-pelejar-por-jesus/',
      ),
      Hino(
        codigo: 348,
        titulo: 'SÊ VALENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na batalha contra o mal, sê valente! \nSegue em marcha triunfal, sê valente! \nOlha o alvo que é Jesus, \nQue à vitória te conduz; \nÓ não deixes tua cruz, \nSê valente!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sê valente! Pelejando por Jesus, \nSê valente! Nunca rejeitando a cruz! \nFirme sempre no amor, \nCom indômito valor, \nCheio do Consolador, \nSê valente!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se o maligno t\'enfrentar, sê valente! \nLutarás sem recuar, sê valente! \nSeja aqui, ou onde for, \nEscudado no Senhor, \nMostrarás o teu valor \nSê valente!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Co\'altruísmo, com poder, sê valente! \nFranco, sem o mal temer, sê valente! \nAos caídos em redor, \nManifesta-lhes o amor; \nE serás um vencedor; \nSê valente!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Evangelho a proclamar, sê valente! \nNo Brasil, em terra ou mar, sê valente! \nTua vida enobrecer! \nSempre com Jesus viver, \nE a ti também vencer; \nSê valente!',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/se-valente/',
      ),
      Hino(
        codigo: 349,
        titulo: 'TRABALHAI ORAI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu quero trabalhar p\'ra meu Senhor, \nLevando a Palavra com amor; \nQuero eu cantar e orar, \nE ocupado quero estar, \nSim, na vinha do Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Trabalhai e orai, \nNa seara e na vinha do Senhor; \nMeu desejo é orar, \nE ocupado quero estar \nSim, na vinha do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu quero, cada dia, trabalhar; \nEscravos do pecado libertar; \nConduzi-los a Jesus, \nNosso Guia, nossa Luz, \nSim, na vinha do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu quero ser obreiro de valor, \nConfiando no poder do Salvador; \nSe quiseres trabalhar, \nAcharás também lugar, \nSim, na vinha do Senhor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/trabalhai-orai/',
      ),
      Hino(
        codigo: 350,
        titulo: 'UM PENDÃO REAL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Um pendão real vos entregou o Rei \nA vós, soldados Seus; \nCorajosos, pois, em tudo O defendei, \nMarchando para os céus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Com valor! Sem temor! \nPor Cristos prontos a sofrer! \nBem alto erguei o Seu pendão, \nFirmes sempre, até morrer!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis formados já os negros batalhões \nDo grande usurpador! \nDeclarai-vos, hoje, bravos campeões; \nAvante sem temor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem receio sente no seu coração, \nE fraco se mostrar, \nNão receberá o eterno galardão, \nQue Cristo tem p\'ra dar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois sejamos, todos, a Jesus leais, \nE a Seu real pendão; \nOs que na batalha sempre são fiéis, \nCom Ele reinarão.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/046-um-pendao-real/',
      ),
      Hino(
        codigo: 351,
        titulo: 'VAMOS NÓS TRABALHAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos nós trabalhar, somos servos de Deus, \nE o Mestre seguir no Caminho aos Céus! \nCom o seu bom conselho o vigor renovar, \nE fazer diligentes o que ele ordenar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'No labor, com fervor, \nA servir a Jesus, \nCom esperança e fé, com oração, \nAté que volte o Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos nós trabalhar e os famintos fartar! \nPara a fonte os sedentos com pressa levar! \nSó na cruz do Senhor nossa glória será, \nPois Jesus salvação graciosa nos dá!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos nós trabalhar, muito trabalho há! \nQue o reino das trevas desfeito será. \nMas o nome exaltado terá Jeová, \nPois Jesus salvação graciosa nos dá!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos nós trabalhar, ajudados por Deus! \nQue a c\'roa e vestes nos dá lá no Céus! \nA mansão dos fiéis nossa certa será. \nPois Jesus salvação sempiterna nos dá!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/trabalho-cristao/simplificada.html',
      ),
      Hino(
        codigo: 352,
        titulo: 'VAMOS A ESCOLA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos, jovens alunos, à escola, \nA Palavra de Deus estudar. \nBoas novas ouvimos de Cristo, \nE favores reais alcançar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Vem, sim, vem à escola comigo \nOuvir boas novas dos céus; \nBoas coisas na escola aprendemos \nDa bendita Palavra de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos, jovens alunos, à escola, \nPois queremos louvar ao Senhor, \nSeus conselhos ouvir com respeito \nQue se ensinam ali com amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó Jesus, sê presente na escola, \nInspirando-nos santo poder, \nE que sempre do estudo aqui feito \nMuito fruto possamos colher.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/vamos-escola/',
      ),
      Hino(
        codigo: 353,
        titulo: 'MAIS UM TEMPLO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Hoje, inaugura-te aqui, santo Deus, \nMais um padrão de teu amor; \nUm novo templo, fanal para os céus, \nCausa de mais louvor!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Glória a Deus, glória  Deus! \nCantem os filhos teus! \nGlória a Deus, glória a Deus! \nGlória nos altos céus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Casa de cultos e fonte de luz, \nOnde o Senhor dá salvação \nPelo evangelho que trouxe Jesus \nCom tanta compaixão!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Marco sublime da proclamação \nDo teu amor, do teu querer; \nOs pecadores aqui ouvirão \nQual é o seu dever.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seja esta casa lugar de oração, \nHabitação certa de Deus, \nPorta do céu e lugar de perdão, \nVida de paz dos céus!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 354,
        titulo: 'AS FIRMES PROMESSAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'De Deus mui firmes são as promessas \nMais firmes que as montanhas são; \nQuando o socorro terrestre cessa, \nOs de Deus não falharão!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'De Deus mui firmes são as promessas, \nFalhando tudo, não falharão; \nSe das estrelas o brilho cessa, \nMas as promessas brilharão!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se a fé te falta, nos teus apertos, \nNas Suas promessas descansa em paz. \nQuando és tentado estou bem certo \nQue Cristo auxílio te traz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se a febre arde, se extingue a vida \nE quer a morte te arrebatar, \nNas Suas promessas terás guarida \nBastante p\'ra te abrigar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Promessas temos que ao Céu de gozo \nVirá levar-nos o Rei Jesus; \nEntão ao crente fiel, corajoso, \nDará coroa de luz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/as-firmes-promessas/',
      ),
      Hino(
        codigo: 355,
        titulo: 'A FÉ CONTEMPLADA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus promete grandes coisas conceder \nA qualquer que peça, crendo que há de obter \nA resposta, sem na fé enfraquecer. \nSua fé Jesus contemplará.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sua fé Jesus contemplará; \nSim, o que Jesus promete dá. \nEle vê o coração, e responde a petição; \nSua fé Jesus contemplará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus tem prometido a quem não duvidar \nDar-lhe tudo quanto a Ele suplicar; \nEle o prometeu e não irá negar! \nSua fé Jesus contemplará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus já grandes maravilhas operou \nPor alguém que firme nEle confiou, \nE que da promessa em nada duvidou! \nJesus Cristo a fé contemplará.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sim, creiamos no que Deus nos prometeu, \nPois jamais desonrará o nome seu; \nEle cumprirá promessas que nos deu \nJesus Cristo a fé contemplará!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/160-a-fe-contemplada/',
      ),
      Hino(
        codigo: 356,
        titulo: 'BEM-AVENTURADO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem-aventurado o que confia \nNo Senhor, como fez Abraão; \nEle creu, ainda que não via, \nE, assim a fé não foi em vão. \nÉ feliz quem segue fielmente, \nNos caminhos santos do Senhor, \nNa tribulação é paciente, \nEsperando no seu Salvador',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os heróis da Bíblia Sagrada, \nNão fruíram logo seus troféus; \nMas levaram sempre a cruz pesada, \nPara obter poder dos céus, \nE depois, saíram pelo mundo, \nComo mensageiros do Senhor, \nCom coragem e amor profundo, \nProclamando Cristo, o Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem quiser de Deus ter a coroa, \nPassará por mais tribulação; \nÀs alturas santas ninguém voa, \nSem as asas da humilhação; \nO Senhor tem dado aos Seus queridos, \nParte do Seu glorioso ser; \nQuem no coração for mais ferido, \nMais daquela glória há de ter.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando aqui as flores já fenecem, \nAs do Céu começam a brilhar; \nQuando as esperanças desvanecem, \nO aflito crente vai orar; \nOs mais belos hinos e poesias, \nForam escritos em tribulação, \nE do Céu, as lindas melodias, \nSe ouviram, na escuridão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sim, confia tu, inteiramente; \nNa imensa graça do Senhor; \nSeja de ti longe o desalento \nE confia no Seu santo amor \nAleluia seja a divisa, \nDo herói e todo vencedor; \nE do céu mais forte vem a brisa, \nQue te leva ao seio do Senhor',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/bem-aventuranca-do-crente/gwgmtw.html',
      ),
      Hino(
        codigo: 357,
        titulo: 'CONFIA EM DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vida tem tristezas mil \nNem tudo é um céu de anil, \nMas contra a dor que é tão sutil, \nHá um caminho só.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Confia em Deus que Ele sempre te ouvirá; \nConfia em Deus que Ele nunca falhará; \nConfia em Deus que a nuvem negra passará, \nOh! Não duvides, mas confia em Deus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando teu céu escurecer \nE a sós penares teu sofrer \nNão desanimes, pra vencer \nHá um caminho só.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E se tua fé provada for \nE te esqueceres do Senhor, \nNecessitando um Salvador, \nHá um caminho só.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/273-confia-em-deus/',
      ),
      Hino(
        codigo: 358,
        titulo: 'CANTA, Ó CRENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Canta com vida, ó crente! \nDoce será cantar! \nAnda só para a frente, \nDeixa o teu pesar; \nCanta nas noites tristes, \nCanta no sol, na luz \nO mal assim resistes: \nCanta p\'ra Jesus! ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Canta com vida, ó crente, \nAlegra o coração! \nLouva ao Deus clemente \nCom feliz canção! \nCheio está o mundo \nDe turbação e dor; \nCanta o amor profundo \nDo teu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Canta com vida, ó crente! \nDeus teu socorro é; \nGuarda-te a Mão potente, \nSe tiveres fé. \nCristo, sim, te levanta, \nQuando medroso estás, \nSe confiando cantas \nSeu amor veraz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/canta-crente/gtzzwm.html',
      ),
      Hino(
        codigo: 359,
        titulo: 'EU CREIO SIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Té conhecer o amor sem fim, \nUm pecador fui eu; \nEm o meu pensar não houver lugar \nPara Cristo e o céu.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu creio, sim, já creio, sim, \nJesus morreu por mim; \nPelo sangue Seu, que Ele verteu, \nLibertado fui por fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pois, quando vi Jesus por mim, \nSofrendo sobre a cruz, \nO meu coração, sem hesitação, \nRecebeu o amor e a luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com lágrimas, pedi perdão, \nE dor, também senti; \nVeio, então, Jesus, e a mim falou; \n“Foi por ti que eu morri”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu sei que Deus, no Filho Seu, \nMe vê perfeito e são; \nNão há mais temor, só bendito amor, \nGozo no meu coração.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/leandro-izauto/59-eu-creio-sim/',
      ),
      Hino(
        codigo: 360,
        titulo: 'ESTOU SEGUINDO A JESUS CRISTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Estou seguindo a Jesus Cristo \nDeste caminho eu não desisto, \nEstou seguindo a Jesus Cristo \nAtrás não volto não volto não. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Atrás o mundo, Jesus à frente \nJesus é o guia Onipotente \nAtrás o mundo, Jesus à frente, \nAtrás não volto não volto não.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se me deixarem os pais e amigos \nSe me cercarem muitos perigos \nSe me deixarem os pais e amigos \nAtrás não volto não volto não ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Depois da luta vem a coroa \nA recompensa é certa e boa \nDepois da luta vem a coroa \nAtrás não volto, não volto não.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/corinhos-evangelicos/estou-seguindo-a-jesus-cristo/',
      ),
      Hino(
        codigo: 361,
        titulo: 'GUARDA O CONTACTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres, neste mundo, ser um vencedor? \nQueres tu cantar nas lutas e na dor? \nQueres ser alegre, qual bom lutador? \nGuarda o contacto com teu Salvador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Guarda o contacto com teu Salvador, \nE a nuvem do mal não te cobrirá; \nPela senda alegre, tu caminharás \nIndo em contacto com teu Salvador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Neste mundo, vivem muitos a penar, \nCujos corações transbordam de pesar; \nDá-lhes a mensagem de amor sem par; \nCom Deus o contacto deves tu guardar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Queres tu, com Deus, a comunhão obter? \nSua glória em ti sempre permanecer? \nQue o mundo possa Cristo em ti ver! \nGuarda o contacto co\'o supremo Ser.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deixa que o Espírito implante em teu ser, \nO amor de Cristo, divinal prazer; \nQueres, neste mundo, todo mal vencer? \nGuarda o contacto e terás poder!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/guarda-contacto/',
      ),
      Hino(
        codigo: 362,
        titulo: 'DESEJO INFANTIL',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou um infantil, gosto de brincar, \nMas o mundo vil quero desprezar; \nSempre a Cristo honrar, seu querer fazer, \nSua lei amar, eis o meu prazer!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Aleluia! Aleluia! \nAmo o meu Jesus! \nAleluia! Aleluia! \nQuer andar na luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou um infantil, corro “atrás da flor”, \nMas no bom redil, onde o meu Senhor \nCom seu povo está, quero respeitar; \nE ele me ouvirá toda a vez que orar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou um infantil, quase nada sei, \nMas meu ser gentil eu a Cristo dei. \nAmo o meu Jesus, Ele me remiu, \nBusco  a sua luz, minha voz ouviu!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou um infantil, tenho pouca fé, \nMas o meu Brasil quero ver de pé \nTento fé em Deus, salvo por Jesus, \nSendo os filhos seus campeões da luz!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 363,
        titulo: 'HINO DE AMOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu canto um hino inspirado \nPor Jesus meu Redentor. \nJamais aqui soou com tal fervor, \nDoce canto de amor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh, que belo hino Deus me deu, \nMe pôs no coração, dulcíssima canção. \nOh, que belo hino Deus me deu \nUm hino do divino amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu amo a Cristo que foi morto \nSobre a cruz p\'ra me salvar, \nJesus um hino em meus lábios pôs \nPara Deus melhor louvar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando estiver lá na glória, \nVendo os anjos a cantar, \nQue belo hino vou ouvir então \nLá no meu eterno lar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/novo-hinario-adventista/oh-que-belos-hinos/',
      ),
      Hino(
        codigo: 364,
        titulo: 'LOUVAI-O, LOUVAI-O',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Louvai-o, louvai-o todas as crianças, \nDeus é amor, Deus é amor. \nLouvai-o, louvai-o todas as crianças \nDeus é amor, Deus é amor. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amai-o, amai-o todas as crianças \nDeus é amor, Deus é amor. \nAmai-o, amai-o todas as crianças \nDeus é amor, Deus é amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Servi-o, servi-o todas as crianças \nDeus é amor, Deus é amor \nServi-o, servi-o todas as crianças \nDeus é amor, Deus é amor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/466--louvai-o/',
      ),
      Hino(
        codigo: 365,
        titulo: 'VAI BUSCAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ouço o clamor do bom Pastor \nPelo deserto abrasador, \nSeus cordeirinhos a chamar, \nMui desejoso de os salvar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vai buscar! Vai buscar! \nMeus cordeirinhos vai buscar! \nVai buscar! Vai buscar! \nPara que os possa abençoar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quem não deseja auxiliar \nSeus cordeirinhos a guardar \nE encaminha-los a Jesus. \nFonte de vida, amor e luz?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo deserto a padecer, \nPelas estradas a morrer, \nSeus cordeirinhos vai buscar, \nPara que os possa abençoar.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/vai-buscar/',
      ),
      Hino(
        codigo: 366,
        titulo: 'VINDE MENINOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vinde, meninos, vinde a Jesus; \nEle ganhou-vos, bênçãos na cruz! \nOs pequeninos Ele conduz; \nOh! Vinde ao Salvador!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Que alegria, sem pecado ou mal, \nReunidos todos, afinal, \nNa santa pátria celestial, \nPerto do Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já, sem demora a todos convém \nIr caminhando à glória de além; \nCristo vos chama, quer vosso bem, \nOh! Vinde ao Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que ama os meninos, Cristo vos diz, \nEle quer dar-vos vida feliz. \nPara habitar no lindo país, \nOh! Vinde ao Salvador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis a chamada: “Vinde hoje a Mim!” \nOutro não há que vos ame assim; \nSeu é o amor que nunca tem fim, \nOh, vinde ao Salvador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/vinde-meninos/',
      ),
      Hino(
        codigo: 367,
        titulo: 'A PAZ DO CÉU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Maravilhoso e sublime p\'ra mim, \nSim, nunca me esquecerei, \nDia glorioso em que a Cristo eu vi \nE o coração lhe entreguei, \nOh! Quão precioso amigo Ele é. \nSalvou-me da perdição \nTirando as culpas, das trevas livrando \nE trazendo-me pleno perdão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A paz do céu encheu meu coração \nQuando Jesus me deu a salvação \nMinh\'alma então lavou \nE a luz em mim raiou \nA paz do céu encheu meu coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Grande esperança Jesus já me deu \nQue não desvanecerá, \nHá uma gloriosa morada no céu \nQue breve minha será.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo porque neste dia feliz \nO meu Senhor aceitei, \nGrandes riquezas e bênçãos celestes \nDas mãos divinas alcancei.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 368,
        titulo: 'COM CRISTO É CÉU',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Depois que Cristo me salvou, \nEm céu o mundo se tornou; \nAté no meio do sofrer \nÉ céu a Cristo conhecer',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Aleluia! Sim, é céu \nFruir perdão que concedeu! \nEm terra ou mar, seja onde for, \nÉ céu andar com o Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pra mim mui longe estava o céu, \nMas, quando Cristo me valeu, \nFeliz, senti meu coração \nEntrar no céu da retidão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem pouco importa eu ir morar \nEm alto monte, à beira-mar, \nEm casa ou gruta, boa ou ruim, \nCom Cristo aí é céu pra mim.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/com-cristo--ceu/',
      ),
      Hino(
        codigo: 369,
        titulo: 'CANTA MEU POVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus ia caminhando \nSubindo pra Jerusalém \nCom Ele iam seus discípulos \nE os fariseus também. \nOs discípulos se alegravam, \nCantavam e davam louvor, \nDizendo: “Bendito é o Rei \nQue vem em nome do Senhor”.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Canta, meu povo, alegra, meu povo, \nQue a festa não vai acabar, \nQuando findar na terra \nNo céu vai continuar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os fariseus murmuravam, \nFalavam com ansiedade: \n“Manda que o povo cale, \nNão perturbe a cidade”. \nJesus olhando pra eles, \nLhes disse com satisfação: \n“Se estes se calarem \nLogo as pedras clamarão”.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E nós que sabemos disto, \nPois foi Jesus quem falou, \nAntes que as pedras clamem, \nNós clamamos ao Senhor. \nJesus desceu da sua glória, \nPara nos trazer Salvação \nNão há ninguém que tire, \nO gozo do meu coração.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/jair-pires/canta-meu-povo/',
      ),
      Hino(
        codigo: 370,
        titulo: 'FILHO PRÓDIGO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu andei desviado no mundo \nAs riquezas que tinha eu gastei \nTodos bens que Deus tinha me dado \nNo pecado e no mundo gastei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu voltei pra Jesus e ele me libertou \nJeová é bom pai, Ele me esperou \nColocou em meu dedo um brilhante \nE com o Espírito Santo, Ele me batizou',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando um dia eu andava com fome \nEmpregado de dor eu sentia \nCom angústia comendo as migalhas \nDas comidas que os porcos comiam.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Coloquei os meus pés na estrada \nPara a casa do pai eu marchei \nE chegando falei com meu pai \nContra ti fortemente eu pequei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero ser um dos seus jornaleiros \nPra servir na seara do Senhor \nMe segura me guarda contigo \nNão me deixes pra o mundo eu voltar.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 371,
        titulo: 'JESUS É MELHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus é melhor, sim, que o ouro e bens. \nJesus é melhor do que tudo que tens, \nMelhor que riquezas e posições, \nMelhor muito mais do que milhões.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Pode ser um rei com poder nas mãos \nMas do mal escravo sim \nMil vezes prefiro o meu Jesus, \nE servi-lo até o fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus é melhor que qualquer valor \nAmigo leal no prazer e na dor, \nMelhor do que tudo, Ele é pra mim, \nMelhor que qualquer bom amigo enfim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus é mais puro que a linda flor, \nJesus é melhor, Ele sim, satisfaz \nJesus é melhor, sim, Ele é amor, \nCaminho, luz, verdade e paz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/jesus--o-melhor/',
      ),
      Hino(
        codigo: 372,
        titulo: 'NO CÉU EU VEJO, ESPLENDENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No céu eu vejo, esplendente, do sol a clara luz; \nViver eu quero somente, brilhando por Jesus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Brilhando, brilhando \nBrilhando qual doce luz. \nBrilhando, brilhando \nBrilhando por meu Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em tudo quero exalta-lo, na escola e no estudar; \nTambém não quero olvida-lo em casa e no brincar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amável com toda gente, assim me quer Jesus; \nAlegre, rosto contente, brilhando como a luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do feio e triste pecado, Jesus, vem me guardar; \nPor Ele sempre amparado, eu quero, sim, andar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se assim é a tua vontade, brilhando viverei; \nE, pela sua bondade; pra o lindo Céu irei',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/salmos-e-hinos-hinario-congregacional/sh-595-brilhando-por-jesus/',
      ),
      Hino(
        codigo: 373,
        titulo: 'NA BÍBLIA ESTÁ ESCRITO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na Bíblia está escrito. \nNo Novo Testamento, \nEm Caná da Galiléia, \nJesus foi a um casamento. \nTransformando água em vinho \nDando ao povo pra beber, \nMostrando sua graça, \nSua glória, seu poder! \nPor quê?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo tem poder! Cristo tem poder! \nCristo tem poder! \nAleluia tem poder! \nCristo tem poder! Cristo tem poder! \nJesus Cristo é poderoso, Jesus Cristo tem poder!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na cidade de Naim, \nEstava uma mulher chorando \nSeu filho ia pra o túmulo \nE o povo carregando. \nJesus parou o enterro \nE o povo reprovou \nJesus chamou o morto \nE o morto levantou \nPor quê?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus curou um cego, \nEntrando em Jericó \nSalvou a Samaritana \nLá no poço de Jacó \nNo monte das Oliveiras \nMultidões aconselhou; \nCinco pães e dois peixinhos \nCinco mil alimentou \nPor quê?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus fez maravilhas, \nNo deserto da Judéia. \nCurou em Samaria \nE também na Galiléia. \nE em Cafarnaum, \nMilagres também fez, \nCurou lá no caminho \nDez leprosos duma vez. \nPor quê?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus fez maravilhas, \nEstá fazendo e vai fazer, \nNão faz na sua vida \nÉ porque você não crê. \nEle salva o pecador \nDá alegria, gozo e paz \nCura toda enfermidade \nE expulsa satanás',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/corinhos-evangelicos/cristo-tem-poder/',
      ),
      Hino(
        codigo: 374,
        titulo: 'NÃO SEI PORQUE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não sei porque de Deus o amor \nA mim se revelou, \nPorque razão o Salvador \nP\'ra Si me resgatou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu sei em quem tenho crido, \nE estou bem certo que é poderoso \nPra guardar o meu tesouro \nAté o dia final.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ignoro como o Espírito \nConvence-nos do mal, \nRevela Cristo, Verbo seu, \nConsolador real.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não sei o que de mal ou bem \nÉ destinado a mim; \nSe maus ou áureos dias vêm, \nAté da vinda o fim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E quando vem Jesus não sei, \nSe breve ou tarde vem; \nMas sei que meu Senhor virá \nNa glória que Ele tem.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/377-nao-sei-porque/',
      ),
      Hino(
        codigo: 375,
        titulo: 'QUE MUDANÇA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Que mudança em mim fez o meu bom Jesus, \nVindo Ele ao meu coração. \nDeu-me paz divinal, deu-me gozo e luz, \nEntrando no meu coração!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Entrando no meu coração! \nEntrando no meu coração! \nQue mudança em mim fez o meu bom Jesus \nVindo ele ao meu coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu andava perdido, Jesus me salvou, \nEntrando no meu coração. \nMeus pecados sem conta, Seu sangue lavou, \nVindo Ele ao meu coração!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E agora, do céu, a certeza me deu, \nEntrando no meu coração. \nSeu Espírito, o selo e penhor concedeu, \nVindo Ele ao meu coração',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelo vale da morte não temo passar! \nCom Ele no meu coração; \nA cidade celeste me vai transportar, \nO guarda do meu coração.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/harpa-crista/que-mudanca/',
      ),
      Hino(
        codigo: 376,
        titulo: 'ROSA VERMELHA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Olhando este mundo ele viu grande multidão \nAndando sozinha sem nada na mão \nSua vida foi rosa vermelha cravada na cruz \nQuem passou por Ele teve compaixão.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A rosa murchando, sangrando, esvairando em dor \nPerdendo a cor sem respiração \nMas o seu perfume se apega à mão que a esmagou \nE quem a feriu concedeu perdão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Agora seu sangue vertido caído no chão \nTrês dias morrendo, oh! Que solidão \nNo terceiro dia o mundo encheu-se de flores \nE a rosa vermelha de novo brotou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus é o lírio dos vales rosa de Sarom \nAté seus espinhos são marcas de amor \nAgora ele vive a plantar num grande jardim \nSe você quiser serás uma flor, \.\.\.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/rosa-vermelha/',
      ),
      Hino(
        codigo: 377,
        titulo: 'TENHO LUZ NO CORAÇÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Toda a escuridão da noite é hoje sol, \nTenho luz no coração. \nVivo agora à luz de um rútilo arrebol, \nTenho luz no coração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tenho luz, sim, tenho luz no coração, \nPois Jesus as trevas todas dissipou; \nDoces hinos cantarei, \nPois Jesus hoje é meu Rei \nTenho luz, sim, tenho luz no coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Minha vida gozo infindo sempre tem, \nTenho luz no coração, \nSei que vou um dia estar no lar de além, \nTenho luz no coração.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 378,
        titulo: 'VIVI TÃO LONGE DO SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vivi tão longe do Senhor, \nAssim eu quis andar. \nAté que eu encontrei o amor. \nEm seu bondoso olhar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Seu maravilhoso olhar \nTransformou meu ser.              (Bis)\nTodo o meu viver, \nSeu maravilhoso olhar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seu corpo vi na rude cruz \nSofrendo ali por mim. \nE ouvi a voz do meu Jesus: \n“Por ti morri assim.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em contrição então voltei \nÀ fonte desse amor. \nPerdão e paz em Cristo achei. \nPertenço ao Salvador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/190-seu-maravilhoso-olhar/',
      ),
      Hino(
        codigo: 379,
        titulo: 'VOU CONTAR-VOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vou contar-vos o que penso do meu Mestre \nComo d\'Ele recebi a luz e a paz \nEle mudou-me eu bem sei perfeitamente \nComo Cristo, nenhum outro satisfaz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Sempre cuidará de mim, meu Mestre, \nCom desvelo e compaixão sem fim, \nNenhum outro tira a culpa do pecado \nOh! Como Ele ama a mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com a vida toda cheia de pecado, \nNa miséria e com dor no coração; \nEl\'me ergueu com braço forte de ternura \nDeu-me gozo, deu-me paz, consolação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cada dia Ele vem com segurança \nMais e mais a revelar o seu amor, \nComo anelo compreender completamente \nEsse amor tão divinal, restaurador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu maior desejo agora é amá-LO \nProclamar o que Ele fez p\'ra me salvar \nE cantando Esse amor inigualável \nEspero em Deus, a minha vida terminar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-adventista/122-o-que-penso-de-meu-mestre/simplificada.html',
      ),
      Hino(
        codigo: 380,
        titulo: 'AS TREVAS JÁ PASSARAM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As trevas já passaram, \nE veio um clarão, \nO brilho da verdade \nEnvolve o meu pobre coração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tenho alegria, gozo, paz e amor, \nVivo para Cristo, o nosso Salvador, \nE assim, vou caminhando \nCom as bênçãos do Senhor, \nLevando a  mensagem \nQue cura e liberta o pecador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tanto sofrimento que no mundo há, \nQuantos que têm sede \nE vivem a procurar \nDe um lado para outro \nA água para a sede saciar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pego no cantil, dou-lhes de beber \nDa água da vida, que faz renascer, \nE assim vou trabalhando, \nAlegre na seara do Senhor, \nAlegre na seara do Senhor,',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 381,
        titulo: 'AMOR DE VENCE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amor, que por amor desceste! \nAmor, que por amor morreste! \nAh! Quanto dor não padeceste, \nMeu coração p\'ra conquistar, \nE meu amor ganhar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amor, que com amor seguias! \nA mim, que sem amor Tu vias! \nOh! Quanto amor por mim sentias, \nMeu Salvador, meu bom Jesus, \nSofrendo sobre a cruz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amor, que tudo me perdoas! \nAmor, que até mesmo abençoas! \nUm réu de quem Te afeiçoas! \nPor ti vencido, ó Salvador, \nEis-me aos teus pés, Senhor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Amor, que nunca, nunca muda, \nQue nos Teus braços me segura, \nCercando-me de mil venturas! \nAceita agora Salvador, \nO meu humilde amor!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/amor-que-vence/hhtsmp.html',
      ),
      Hino(
        codigo: 382,
        titulo: 'A FONTE TRANSBORDANTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que fonte transbordante! \nMais profunda que o mar. \nÉ de Deus, o amor imenso, \nQue Jesus me veio dar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ele me abriu a porta, \nE me reconciliou, \nPor Seu sangue derramado; \nPara Deus me consagrou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como a pomba perseguida \nE cansada, estava eu, \nMas Jesus jamais rejeita, \nQuem buscar abrigo Seu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Graça abundantemente \nSobre mim já derramou; \nOnde abundou o pecado, \nGraça superabundou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando alvorecer meu dia, \nCom Jesus, irei p\'ro Céu: \nEu O exaltarei p\'ra sempre, \nPois salvou um perdido réu.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/a-fonte-transbordante/',
      ),
      Hino(
        codigo: 383,
        titulo: 'BANQUETE DE BELSAZAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Numa orgia nefanda, \nO rebelde Balsazar, \nCom os grandes do seu reino, \nTodos eles a folgar, \nCom espanto pararam \nQuando o rei estremeceu: \nNa parede a mão divina, \nEscrevendo, apareceu.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Lá no céu a mão de Deus! \nLá no céu a mão de Deus! \nVê qual seja a tua sorte \nA tua vida ou morte: \nLá no céu escreve a mão de Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No palácio, os festivos \nNobres não souberam ler \nTal escrita na parede; \nLogo, o rei, todo a tremer, \nVir mandou bem depressa \nO cativo Daniel \nQue, do escrito na parede, \nDeu a tradução fiel.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A sentença foi grave \nAo monarca dos caldeus, \nQue vivia no pecado, \nSem temor nenhum de Deus; \n“O teu reino passou-se; \nna parede escrito está; \na balança da justiça \na tua alma em falta está.”',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tua vida, ó amigo, \nNesta hora escrita está; \nO registro dos teus atos \nDeus, no céu, escreve já; \nQue Jesus, pois, te faça \nTal escrita compreender, \nQue, em havendo tempo, possas \nSua graça receber',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 384,
        titulo: 'CÔRO SANTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que belos hinos cantam lá nos céus, \nPois do mundo o filho mau voltou! \nVêde no caminho o bom Pai abraçar, \nEsse filho que Ele tanto amou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Glória, glória os anjos cantam lá! \nGlória, glória as harpas tocam já! \nÉ o santo côro, dando glória a Deus, \nPor mais um remido entrar nos céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que belos hinos cantam lá nos céus! \nÉ que já se reconciliou \nA alma revoltosa, que submissa a Deus, \nConvertida o mundo abandonou!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó arrependidos, hoje festejai, \nComo os anjos fazem com fervor! \nIde, pressurosos, vós, e anunciai \nQue se resgatou um pecador!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/274-coro-santo/',
      ),
      Hino(
        codigo: 385,
        titulo: 'CARREIRA CRISTÃ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na mais bela carreira da vida \nProclamando o divino perdão \nVoz do céu com amor te convida \nFilho meu dai-me o teu coração!',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Quem atende tão grande convite \nInicia a carreira cristã \nTem as bênçãos do amor sem limite \nGoza  paz, sim, em cada manhã.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na carreira cristã gloriosa \nOs tesouros da Bíblia são teus \nTua estrada será luminosa \nSob a luz da Palavra de Deus!',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Sem cessar leve a Deus tua prece \nNão vacile jamais o teu pé \nPois contigo o Senhor permanece \nNa sublime carreira da fé.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na carreira de eternos valores \nO cristão muitos frutos produz \nÉ fiel nos sagrados labores \nE reflete o esplendor de Jesus.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'O Evangelho empunhando a bandeira \nBandeirando o mais belo e real \nRecebendo na santa carreira \nUma glória da vida eternal',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 386,
        titulo: 'CANTAI',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O meu coração sofredor \nDescanso seguro encontrou, \nSeguindo os Conselhos de amor. \nDo Pai que do mal me chamou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cantai, cantai \nNo templo de nosso Senhor! \nCanta, cantai \nAo mundo mostrai seu amor!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nos astros esparsos nos céus, \nDa lua no branco clarão, \nEu leio poemas de Deus \nQue outorga aos contritos perdão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No livro bendito encontrei \nPalavras de amor e de luz; \nE canto celeste escutei \nDos anjos, saudando Jesus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Os males do mundo olvidei; \nPor isso me pus a cantar; \nCom Deus para sempre estarei, \nIrei com Jesus ao seu lar.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/cantai/',
      ),
      Hino(
        codigo: 387,
        titulo: 'FINDA-SE ESSE DIA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Finda-se este dia que meu Pai me deu, \nSombras vespertinas cobrem já o céu. \nÓ Jesus bendito; se comigo estás, \nEu não temo a noite, vou dormir em paz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'C\'os pecados d\'hoje eu te entristeci, \nMas perdão Te peço por amor de Ti. \nSou tão pequenino! Livra-me do mal. \nE em sossego alcanço pouso natural.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Guarda o marinheiro no violento mar, \nE ao que sofre dores queiras confortar, \nAo tentado estende tua mão, Senhor! \nManda ao triste e aflito o Consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelos pais e amigos, pela santa Lei. \nPelo amor divino graças Te darei. \nÓ Jesus, aceita minha petição, \nE seguro durmo, sem hesitação.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-luterano/finda-se-este-dia/',
      ),
      Hino(
        codigo: 388,
        titulo: 'HÁ UM CANTO NOVO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há um canto novo no meu ser, \nÉ a voz de meu Jesus, \nQue me chama: “vem em mim obter \nA paz, que eu ganhei na cruz”.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo, Cristo, Cristo, nome sem igual; \nEnches o contrito, de prazer celestial.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Preso no pecado eu me achei, \nSem paz no meu coração; \nMas em Cristo eu já encontrei \nDoce paz e proteção.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho  Sua graça divinal, \nSob as asas de amor, \nE riquezas que fluem em caudal, \nLá do trono do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pelas águas fundas me levou, \nProvas muitas encontrei; \nMas Jesus bendito me guiou \nPor Seu sangue vencerei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo, numa nuvem voltará, \nBaixará do Céu em luz; \nPelo Seu poder me levará, \nP\'ra Seu lar, o bom Jesus. ',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/ha-um-canto-novo/',
      ),
      Hino(
        codigo: 389,
        titulo: 'HÁ MOMENTOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há momentos em que as palavras não resolvem, \nMas o gesto de Jesus na cruz, \nDemonstrou amor por nós, \nHá momentos em que as palavras não resolvem \nMas o gesto de Jesus na cruz, \nDemonstrou amor por nós. ',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Foi no Calvário que Ele sem falar, \nMostrou ao mundo inteiro \nO que é o amar \nFoi no Calvário que Ele sem falar, \nMostrou ao mundo inteiro \nO que é o amar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Aqui no mundo as desilusões são tantas \nMas, existe uma esperança \nÉ que Cristo vai voltar \nAqui no mundo as desilusões são tantas \nMas, existe uma esperança \nÉ que Cristo vai voltar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/corinhos-evangelicos/ha-momentos/',
      ),
      Hino(
        codigo: 390,
        titulo: 'HINO NACIONAL BRASILEIRO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ouviram do Ipiranga às margens plácidas \nDe um povo heróico o brado retumbante, \nE o sol da liberdade, em raios fúlgidos, \nBrilhou no céu da pátria nesse instante.\n\nSe o penhor dessa igualdade \nConseguimos conquistar com braço forte, \nEm teu seio, ó liberdade, \nDesafia o nosso peito à própria morte! \nÓ Pátria amada, idolatrada, salve! Salve!\n\nBrasil, um sonho intenso, um raio vívido \nDe amor e de esperança à terra desce, \nSe em teu formoso céu, risonho e límpido, \nA imagem do Cruzeiro resplandece.\n\nGigante pela própria natureza, \nÉs belos, és forte, impávido, colosso, \nE o teu futuro espelha essa grandeza. Terra adorada \nEntre outras mil, és tu, Brasil, ó Pátria amada! \nDos filhos deste solo és mãe gentil, \nPátria amada Brasil!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deitado eternamente em berço esplendido, \nAo som do mar e à luz do céu profundo, \nFulguras, ó Brasil, florão da América, \nIluminado ao sol do Novo Mundo!\n\nDo que a terra mais garrida \nTeus risonhos, lindos campos têm mais flores; \n“Nossos bosques tem mais vida, \nNossa vida”, no teu seio, "mais amores". \nÓ Pátria amada, idolatrada, salve! Salve!\n\nBrasil, de amor eterno seja símbolo \nO lábaro que ostentas estrelado, \nE diga o verde-louro desta flâmula: \n“Paz no futuro e glória no passado.”\n\nMas, se ergues da justiça a clava forte, \nVerás que um filho teu não foge à luta, \nNem teme, quem te adora, a própria morte. \nTerra adorada, \nEntre outras mil, és tu, Brasil, ó Pátria amada! \nDos filhos deste solo és mãe gentil, \nPátria amada, Brasil!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinos/hino-nacional-brasileiro/',
      ),
      Hino(
        codigo: 391,
        titulo: 'NIVEA LUZ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, eu almejo a pureza do céu, \nTua linda presença no coração meu. \nOs ídolos quebro, me toma Jesus; \nÓ dá-me a pureza da nívea luz.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'Nívea luz, a nívea luz, \nÓ dá-me a pureza da nívea luz.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, me acode enquanto lidar, \nA colocar tudo no santo altar; \nA Ti me entrego; nas chamas me pus; \nÓ dá-me a pureza da nívea luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, com instância, humilde, roguei \nQue o sangue perfeito pureza me dê; \nMe lava na fonte aberta na cruz; \nÓ dá-me a pureza da nívea luz!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, neste instante, espero a mão \nQue há de criar-me o bom coração; \nAqueles que o Espírito pedem de Deus, \nDás sempre a pureza da nívea luz!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/nascimento-silva/nivea-luz/',
      ),
      Hino(
        codigo: 392,
        titulo: 'NÃO MURMURES, CANTA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No mundo murmura-se tanto, \nEntre os que cristãos dizem ser; \nEm vez de louvores h\'pranto, \nFraqueza em lugar de poder. \nMurmuram  assim no deserto, \nEm Mara, Israel murmurou; \nOh! Não vêem que Deus está perto; \nJamais seu auxílio negou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Em vez de murmurares, canta \nUm hino de louvor a Deus; \nJesus quer te dar vida santa, \nQual noiva levar-te p\'ra os céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu vives, irmão murmurando, \nTal como um escravo do mal; \nSe Deus a tua fé \'stá provando, \nTu não tens razão para tal. \nDeus castiga aquele a quem ama, \nDe ti, também não se esqueceu; \nQual pai amoroso te chama, \nE cuida, sim, do que é Seu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E mesmo se as ondas rugirem, \nNo revolto e bravio mar, \nOs Céus poderás ver se abrirem, \nSe um hino tua alma cantar, \nNão temas ciladas, nem morte, \nP\'ra cima tu deves olhar; \nO leme segura bem forte \nAté do céu a luz raiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se um hino cantar tu puderes, \nNas horas de grande aflição, \nEntão voarás, se quiseres, \nAté a celeste mansão; \nNas asas da águia levado, \nBem perto do mar de cristal \nE por fim então libertado, \nA terra, chegar, celestial.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/nao-murmures-canta/gwszkj.html',
      ),
      Hino(
        codigo: 393,
        titulo: 'OBRA SANTA DO ESPÍRITO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Obra Santa do Espírito \nEsta causa é do Senhor. \nComo um vento impetuoso, \nComo fogo abrasador. \nEstamos sobre terra Santa, \nReverência e muito amor, \nEsta hora é decisiva, \nVigilância e destemor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ninguém detém, é obra santa; \nNinguém detém, é obra santa, \nNem satã, nem o mundo todo \nPode apagar este ardor. \nNinguém detém, é obra santa \nEsta causa é do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Em meu peito renovado, \nArde o fogo do Senhor! \nÉ a bênção do Espírito, \nNos enchendo de fervor, \nE Jesus está salvando, \nApagando toda dor; \nNo Espírito batizando, \nPois da vida Ele é o Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis Jesus já vem chegando \nEspalhando suave amor; \nJá se sente o perfume, \nDa unção do Salvador! \nE a igreja adornada \nDe pureza e esplendor, \nAguardando entrar nas bodas \nPra reinar com seu Senhor',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/hinario-aleluia/obra-santa-do-espirito/',
      ),
      Hino(
        codigo: 394,
        titulo: 'REVELA A NÓS, SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus, meu Rei, Mestre e Senhor, \nO teu amor revela a mim, \nEnquanto eu aqui viver, \nAté eu ver da vida o fim.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Revela a nós, Senhor Jesus, meu Salvador, \nAs maravilhas mil do Teu divino amor; \nE com veraz louvor, fervente gratidão; \nEleva a Ti, Jesus Senhor, o nosso coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'As bênçãos mil do Teu amor, \nQual esplendor me cercarão; \nO Teu olhar será, Jesus, \nA grata luz do coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sorrisos Teus verei brilhar, \nSe não andar no mundo vil; \nDesfrutarei prazer veraz, \nTempo de paz primaveril.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E, quando for no céu morar, \nE descansar dos dias meus, \nFeliz viver receberei \nDe Ti, meu Rei, meu Santo Deus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/088-revela-a-nos-senhor/',
      ),
      Hino(
        codigo: 395,
        titulo: 'SE DA VIDA AS VAGAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se da vida as vagas procelosas são, \nSe com desalento, julgas tudo vão, \nConta as muitas bênçãos, dize-as duma vez, \nVerás, com surpresa, quanto Deus já fez.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Conta as bênçãos, conta quantas são, \nRecebidas da divina mão; \nVem dize-las todas duma vez. \nE verás surpreso, quanto Deus já fez',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tens acaso mágoas? Triste é teu lidar? \nE a cruz pesada, que tens de levar? \nConta as muitas bênçãos não duvidarás, \nE em canto alegre os dias passarás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando vires outros com seu ouro e bens, \nLembra que tesouros prometidos tens; \nNunca os bens da terra poderão comprar \nA mansão celeste que vais habitar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Seja o conflito fraco ou forte, cá, \nNão te desanimes: Deus por cima está \nSeu divino auxílio,  minorando o mal, \nTe dará consolo, sempre, até o final.',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/hnc/063-as-muitas-bencaos/',
      ),
      Hino(
        codigo: 396,
        titulo: 'UMA CENTELHA SÓ',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Uma centelha só \nUm grande fogo faz, \nQueimando ao redor, \nA todos calor traz;',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'O amor de Deus assim é, \nQuando você sentir \nO seu imenso amor sem par, \nVocê vai transmitir.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A primavera é \nA mais linda estação, \nAs aves a cantar, \nA flor que nasce do botão. \nO amor de Deus assim é, \nQuando você sentir \nA todos vai querer contar \nVocê vai transmitir',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quero que você conheça \nA felicidade \nIgual a que encontrei, \nQue é realidade. \nDo alto da montanha \nA todos vou falar \nQue encontrei Jesus Senhor \nEu quero transmitir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/andre-cardoso/uma-centelha/',
      ),
      Hino(
        codigo: 397,
        titulo: 'UM POVO FORTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis que surge um povo forte, \nRevestido de poder; \nE não teme nem a morte, \nQuem a ele pertencer; \nE terá sublime sorte, \nPois com Cristo ao Céu vai, \nPodes tu dizer também, \n“Sou um dos tais”?',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Um dos tais. Um dos tais. \nPodes tu também dizer: “Sou um dos tais”? \nUm dos tais, um dos tais, \nPodes tu também dizer: “Sou um dos tais”?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No Cenáculo reunidos, \nO poder buscavam então, \nPelo amor de Deus unidos \nA clamar em oração; \nEis que um vento é descido \nE o fogo do Céu cai; \nPodes tu dizer também; \n“Sou um dos tais”?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Este povo destemido, \n(São os discípulos de Jesus) \nPelo mundo perseguido, \nPor levar a Sua cruz, \nE agora revestido \nCom poder ao mundo sai; \nPodes tu dizer também: \n“Sou um dos tais”?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó não sejas descuidoso \nP’ra buscar o dom de Deus, \nDom que te fará ditoso, \nDart-te-á visões do Céu. \nE Jesus maravilhoso \nProclamando aos outros vais, \nPoderás então dizer: \n“Sou um dos tais”.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/um-povo-forte/tablatura.html',
      ),
      Hino(
        codigo: 398,
        titulo: 'VAMOS Ó IGREJA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tenho gozo e alegria celeste \nQuando vou adorar ao Senhor \nCom os crentes em Cristo, na igreja, \nQuando juntos rendemos louvor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh, vem, sim, vem à igreja comigo, \nSim, vamos servir ao Senhor, \nPois maior alegria não temos \nDo que ter comunhão em amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vamos, crentes em Cristo, à igreja, \nConversar com o nosso bom Deus; \nEscutar os seus ricos conselhos, \nRecolher ricas bênçãos dos céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Com prazer eu aguardo a chegada \nDesse dia do meu Salvador; \nNele, pois, a minha alma, contente, \nSe derrama em ações de louvor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ó meu Mestre divino e amado, \nEu contigo desejo viver; \nTua lei, tua causa e teu povo \nQuero sempre abraçar, defender.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/382-vamos-a-igreja/',
      ),
      Hino(
        codigo: 399,
        titulo: 'VASOS TRANSBORDANTES',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Qual vazio vaso \'stá teu coração, \nPara receber de Deus, a salvação? \nSó Jesus teu vaso poderá encher, \nDe bênçãos que dão poder.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Deixa encher teu vaso até transbordar; \nQue Jesus tua vida possa governar, \nPõe teu sacrifício hoje sobre o altar; \nE verás as bênçãos descer sem cessar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A vida abundante tu receberás, \nE constantemente em Deus te alegrarás, \nQual ribeiro d\'água, o Senhor quer ver \nO deserto florescer.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O Senhor precisa de vasos para encher, \nMas vazios vasos que irão conter \nToda a Sua graça, brasas do altar, \nPara o fogo espalhar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/vasos-transbordantes/cifra.html',
      ),
      Hino(
        codigo: 400,
        titulo: 'CONTA-ME',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Conta-me a história de Cristo, \nGrava-a no meu coração; \nConta-me a história preciosa, \nPois Ele dá salvação. \nConta que os anjos em côro \nDeram louvor a Jeová, \nOh! Glória a Deus nas alturas \nPelo perdão que nos dá!          (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo sofreu no deserto, \nDias amargos passou \nPelo maligno tentado, \nMas em poder triunfou. \nConta dos seus sofrimentos \nQue Ele por nós padeceu \nQuando em terrível angústia \nLá no Calvário morreu!             (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Conta do cálice amargo; \nEle sofreu maldição! \nConta do triste sepulcro, \nConta da ressurreição. \nOh! Grande amor indizível! \nGraça e fervor divinal! \nSantos louvores cantemos\nAo Salvador eternal!                (Bis) ',
          ),
        ],
        urlCifraSite: 'https://www.cifraclub.com.br/cantor-cristao/conta-me/',
      ),
      Hino(
        codigo: 401,
        titulo: 'HÁ SEMPRE ALGUÉM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Há sempre alguém que não provou \nO grande amor de meu Senhor. \nPorém, eu sei, bem certo estou, \nQue Ele está sempre ao meu redor pra me guiar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Ao meu redor, Deus sempre está \nAo meu redor, ao meu redor, pra me guiar; \nCom seu amor tão puro e bom \nEle está sempre ao meu redor pra me guiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Posso perder todos os meus bens, \nE um bom amigo me faltar. \nPode meu pai me abandonar, \nQue Ele está sempre ao meu redor pra me guiar.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não sei contar o que senti, \nQuando Jesus me redimiu \nDesde então eu descobri \nQue Ele estará ao meu redor quando eu partir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/luiz-de-carvalho/ha-sempre-alguem/',
      ),
      Hino(
        codigo: 402,
        titulo: 'A TUA PALAVRA É SEMENTE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Tua Palavra é semente, \nE Tu és o semeador, \nO meu coração é a terra \nQue Tu semeaste Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'A Tua Palavra, A Tua Palavra, \nA Tua Palavra, Senhor, \nA Tua Palavra, A Tua Palavra, \nA Tua Palavra é amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meditando um certo dia, \nNa Tua Palavra Senhor \nSenti que do alto descia \nA graça do Consolador.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/razao-gospel/a-tua-palavra-e-a-semente/',
      ),
      Hino(
        codigo: 403,
        titulo: 'VIGIAR E ORAR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Bem de manhã, embora o céu sereno \nPareça um dia calmo anunciar, \nVigia e ora; o coração pequeno \nUm temporal pode abrigar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto: 'Bem de manhã, e sem cessar, \nVigiar, sim, e orar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ao meio dia, e quando os sons da terra \nAbafam mais de Deus a voz de amor, \nRecorre à oração, evita a guerra \nE goza paz com o Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Do dia ao fim, após os teus lidares, \nRelembra as bênçãos do celeste amor, \nE conta a Deus prazeres e pesares, \nDeixando em suas mãos a dor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E sem cessar, vigia a cada instante, \nQue o inimigo ataca sem parar. \nSó com Jesus em comunhão constante \nÉ que o fiel vai triunfar.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/162-vigiar-orar/',
      ),
      Hino(
        codigo: 404,
        titulo: 'CHUVAS DE BÊNÇÃOS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chuvas de bênçãos teremos; \nÉ a promessa de Deus, \nTempos benditos verem os, \nChuvas de bênçãos dos céus.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Chuvas de bênçãos, \nChuvas de bênçãos dos céus; \nGotas somente nós temos; \nChuvas rogamos a Deus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chuvas de bênçãos teremos, \nVida de paz e perdão. \nOs pecadores indignos \nGraça dos céus obterão.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chuvas de bênçãos teremos, \nManda-nos, já, ó Senhor! \nDá-nos agora o bom fruto \nDesta palavra de amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Chuvas de bênçãos teremos, \nChuvas mandadas dos céus; \nBênçãos a todos os crentes \nBênçãos do nosso bom Deus.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/168-chuvas-de-bencaos-/',
      ),
      Hino(
        codigo: 405,
        titulo: 'PARA SALVAR-TE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Veio Jesus a este mundo vil \nPara buscar-te a ti, \nFoi rejeitado por gente hostil, \nPara salvar-te a ti. \nGlórias ali no céu deixou, \nIngratidão no mundo achou, \nTudo Ele fez porque te amou, \nPara salvar-te a ti.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Glória, glória, demos ao Salvador! \nGlória, glória, por seu tão grande amor \nGlória, glória! Temos a paz com Deus \nGlória, glória! Vamos cantar nos céus.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O teu castigo Jesus levou \nPara salvar-te a ti; \nTudo na cruz Ele consumou \nPara salvar-te a ti \nQuem dentre os homens compreendeu \nTodas as dores que sofreu, \nA condição em que morreu \nPara salvar-te a ti?',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tudo isto Deus fez em teu favor \nPara salvar-te a ti; \nChama agora com terno amor \nPara perdoar-te a ti. \nDeves chegar em contrição, \nTendo certeza do perdão; \nCristo estende a sua mão \nPara salvar-te a ti.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Que alegria, que gozo e paz \nTer salvação de Deus \nE nova vida que satisfaz \nA alma que busca os céus! \nLivre das culpas do pecar, \nLonge da dor e do chorar, \nTendo certeza de gozar \nA redenção de Deus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/para-salvar-te/',
      ),
      Hino(
        codigo: 406,
        titulo: 'SALMO 137',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Junto ao rio de Babilônia se assentava \nLamentava e chorava Israel, \nPor Sião, e sua pátria que deixava, \nUma terra que manava leite e mel.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cantai hinos de Sião, diziam os caldeus; \nNos alegram com as suas melodias, \nHinos do Senhor aqui em terra estranha \nNão cantamos Israel assim dizia.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Suas harpas penduradas lá estavam \nNos salgueiros, bem distantes de Sião. \nE os tiranos que os levava escravizados \nLhes pediam que entoassem uma canção.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se eu me esquecer de ti, Jerusalém; \nMinha destra esqueça da sua destreza, \nPois és a cidade do meu grande Rei \nAdornada de esplendor e de beleza.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 407,
        titulo: 'OLHA PRA CIMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se cada vez que a tristeza \nVier atingir teu coração. \nLembras que tu tens uma esperança, \nNo poder glorioso da oração.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Olha pra cima, com fé em Jesus, \nNão desanimes, carrega tua cruz \nJesus que era santo, sua cruz carregou; \nFoi até o fim e não desanimou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se caminhos de pedra ferir teus pés; \nSe, às vezes, quiseres desanimar, \nOlhas para Cristo e tenhas fé, \nPois Ele venceu e tu vencerás.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dobre os teus joelhos, busque a Jesus \nEntrega a Ele suas aflições; \nE sinta a paz que Cristo dá \nPois Ele venceu e tu vencerás.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 408,
        titulo: 'A BÍBLIA SAGRADA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Bíblia Sagrada é um livro, \nQue fala do amor de Deus \nÉ ela que nos ensina \nO caminho santo para o céu, \nMaravilhoso este livro \nEscrito com muito poder; \nÉ o livro das profecias \nQue todos devem conhecer',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Como é bom! Oh! Como é bom! \nTer a Bíblia Sagrada, escrita no coração \nOh, como é bom! Oh, como é bom! \nTer a Bíblia Sagrada, escrita no coração.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Bíblia Sagrada é um livro \nQue fala ao coração, \nQue ensina toda verdade \nO caminho da salvação. \nHá um versículo da Bíblia, \nOnde Jesus disse assim: \n“Examinai as Escrituras, \nPois testificam de mim”.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 409,
        titulo: 'A VINDA DO SENHOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Como foi para o céu, Jesus Cristo há de vir, \nQuando o som da trombeta ecoar; \nQuando a voz de um arcanjo no céu estrugir, \nEu irei com Jesus me encontrar.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Que dia faustoso, esse dia há de ser! \nQuando o som da trombeta ecoar, \nQuando Cristo, nas nuvens, tiver de descer \nPara assim entre nós habitar!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Nesse dia de glória meu corpo moral \nSemelhante ao de Cristo há de ser; \nE já livre da morte, e já livre do mal, \nO milênio de Cristo hei de ver.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu aqui, pela cruz, para o mundo morri, \nMuita dor inda aqui sofrerei; \nMinha vida com Cristo em meu Deus escondi, \nE com Cristo eu aqui reinarei.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Vem, Jesus, ó Senhor, vem depressa, reinar, \nVem a paz e a justiça trazer; \nCriação, povo teu, tudo almejo raiar \nDesse dia de glória e poder.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Este império do mal, vem Senhor, destruir, \nVem, Esposo celeste, reinar! \nVem, ó Sol da justiça, no mundo luzir; \nÓ meu Rei, vem meu pranto estancar!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/cantor-cristao/a-vinda-do-senhor/',
      ),
      Hino(
        codigo: 410,
        titulo: 'PROMESSAS DE JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus nos tem prometido, \nDe nos levar para Si \nNo céu a glória não cessa \nComo essa glória daqui \nNo céu o gozo é perene, \nPois, não há pranto e nem dor \nOh! Que promessa solene \nA que nos fez o Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Vamos, vamos, vamos ó filhos da luz, \nVamos, vamos, vamos falar de Jesus \nVamos, vamos, vamos com a Bíblia na mão \nVamos a todas as gentes, anunciar salvação.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Mui brevemente teremos \nUma coroa de luz \nQue Deus já tem preparado \nPara os que crêem em Jesus \nVamos que o mundo perece \nNo vício e no lamaçal, \nPrecisa ser redimido \nE libertado do mal.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jovens, a nossa bandeira \nÉ Cristo o vencedor \nQue nos garante a vitória \nSe lutarmos com amor, \nVamos, sem medo pregar \nA mensagem de poder. \nCertos que, com Jesus Cristo, \nNada iremos temer.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Vamos, sim, vamos contentes, \nVamos ó filhos da luz \nVamos levar a semente, \nVamos falar de Jesus. \nVamos que o mundo perece \nVamos com a Bíblia na mão \nVamos a todas as gentes \nAnunciar salvação ',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 411,
        titulo: 'CIDADE DE REFÚGIO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A morte me perseguia, \nMuito aflito eu corria \nCom medo de perecer \nMas, um dia eu avistei \nA cidade de Refúgio \nQuando alguém me falou:',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Que a cidade é Jesus; \nQue pela morte da cruz                  (Bis) \nMuito alegre me abraçou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na cidade de refúgio \nEu não sabia falar, \nMas, Jesus me ensinou, \nA falar em língua estranha \nPelo Espírito Santo \nQue Jesus me batizou.',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Só preciso ter cuidado \nPara não me desviar                      (Bis) \nDo caminho do Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu amigo estás cansado, \nCarregando o triste fardo \nDe pecado e de dor, \nJesus Cristo quer  tua alma \nEle quer dar-te a paz, \nE salvar-te ó pecador',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'A cidade de refúgio \nAinda está com a porta aberta     (Bis) \nE tem lugar pra ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Na cidade de refúgio, \nTemos paz e alegria \nE o gozo da salvação \nPois Jesus é a cidade \nQue ampara o pecador \nLivrando-o da perdição',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Se quiseres, venha agora, \nJesus Cristo te espera                   (Bis) \nCom amor e com perdão.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 412,
        titulo: 'A MINHA ALMA ESTAVA LONGE',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A minha alma estava longe \nDo caminho de Deus, \nEu era pobre e desprezível pecador, \nMas Jesus já transformou \nMinhas trevas em luz, \nQuando Ele estendeu sua mão para mim.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Quando Jesus estendeu a sua mão, \nQuando Ele estendeu a sua mão para mim, \nEu era pobre e perdido, \nSem Deus, sem Jesus, \nQuando Ele estendeu sua mão para mim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Agora me regozijo \nDesde que O aceitei, \nE na tempestade eu posso sossegar, \nPois com Ele estou liberto \nDo perigo e do mal, \nDesde que estendeu sua mão para mim.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/mattos-nascimento-musicas/quando-jesus-estendeu-a-sua-mao/',
      ),
      Hino(
        codigo: 413,
        titulo: 'VENCENDO VEM JESUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Já refulge a glória eterna \nDe Jesus o Rei dos reis; \nBreve os reinos deste mundo \nSeguirão as suas leis! \nOs sinais da sua vinda \nMais se mostram cada vez \nVencendo vem Jesus!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Glória, glória! Aleluia! \nGlória, glória! Aleluia! \nGlória, glória! Aleluia! \nVencendo vem Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O clarim que chama os crentes \nA batalha, já soou; \nCristo, à frente do seu povo, \nMultidões já conquistou. \nO inimigo em retirada, \nSeu furor patenteou. \nVencendo vem Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eis que em glória refulgente \nSobre as nuvens descerá, \nE as nações e os reis da terra \nCom poder governará \nSim, em paz e santidade, \nToda terra regerá. \nVencendo vem Jesus!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'E por fim entronizado \nAs nações há de julgar, \nTodos grandes e pequenos \nO juiz hão de encarar. \nE os remidos triunfantes, \nEm fulgor hão de cantar: \nVencido tem Jesus!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/525-vencendo-vem-jesus/',
      ),
      Hino(
        codigo: 414,
        titulo: 'PAI DE AMOR',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Pai de amor gosto tanto de Ti; \nPai de amor gosto tanto de Ti; \nTe amo, Te quero, e prostrado Te adoro \nPai de amor gosto tanto de Ti!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu Jesus amoroso Tu és; \nMeu Jesus amoroso Tu és; \nMinha alma já limpaste e o Espírito enviaste \nMeu Jesus amoroso Tu és!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Santo Espírito Consolador; \nSanto Espírito Consolador; \nTu nos santificas e em nós sempre habitas \nSanto Espírito Consolador!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Trino Deus eu me entrego a Ti; \nTrino Deus eu me entrego a Ti; \nDe todo meu ser, imploro o Teu poder \nTrino Deus eu me entrego a Ti!',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/vencedores-por-cristo/pai-de-amor/',
      ),
      Hino(
        codigo: 415,
        titulo: 'CHUVAS DE GRAÇA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Deus prometeu com certeza, \nChuvas de graça mandar; \nEle nos d\'fortaleza, \nE ricas bênçãos sem par.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Chuvas de graça, \nChuvas pedimos, Senhor, \nManda-nos chuvas constantes, \nChuvas do Consolador.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dá-nos, Senhor, amplamente, \nTeu grande gozo e poder; \nFonte de amor permanente, \nPões dentro de nosso ser.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Faze os teus servos piedosos, \nDá-lhes virtude e valor \nDando os teus bens preciosos, \nDo Santo preceptor.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/chuvas-de-graca/simplificada.html',
      ),
      Hino(
        codigo: 416,
        titulo: 'TUDO EM CRISTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dantes trabalhava sempre com temor, \nMas descanso, agora em meu Salvador; \nDantes “esperava”; hoje, “bem o sei” \nQue estou salvo em Cristo, meu bendito Rei.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Tudo! Tudo em Cristo! \nQue por mim morreu. \nTudo! Tudo em Cristo! \nCristo é todo meu.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dantes, desejava bênção do Senhor; \nHoje, mais de Cristo, mais de Seu amor! \nNão somente a bênção, que tão pronto dá, \nMas Ele mesmo é a fonte em quem tudo está.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dantes, duvidava, era sempre “o eu”, \nHoje, bem conheço Cristo além do véu, \nSacerdote eterno, lá por mim entrou; \nNEle estou completo, nEle aceito sou.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Dantes queria o mundo; hoje, é só Jesus! \nDantes, eram trevas; hoje é plena luz; \nDantes, o receio, hoje, a doce paz, \nTudo a Cristo deixo, Ele me satisfaz.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/harpa-crista/056-tudo-em-cristo/',
      ),
      Hino(
        codigo: 417,
        titulo: 'PRECE DE CASAMENTO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu sonho ardente de ventura \nVou realizar. \nSempre sonhei a vida pura \nDe um doce e meigo lar \nE, agora, alegremente, \nDiante do altar \nVenho a Deus humildemente, \nA bênção suplicar. ',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Conserva-nos pra sempre unidos, \nNo gozo ou dor. \nConstantemente aquecidos \nPor teu divino amor, \nQuer na paz; quer na tormenta, \nVem conosco ser \nA nossa vida oriente, \nConforme o teu querer',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O lar que hoje nós formamos, \nVem abençoar. \nE, que em tudo nós possamos, \nTeu santo nome honrar \nQue o lar que tu nos deste \nSeja a imitação; \nDa divinal mansão celeste \nA tua habitação.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 418,
        titulo: 'SEGURANÇA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus me segura na minha jornada \nNão deixe eu cair \nA luta é pesada, eu já estou na estrada \nConfio em Ti. \nEu não tenho medo, sua mão eu percebo \nEstá sobre mim.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu vejo na estrada os espinhos \nMas, não estou sozinho, confio em Ti.   (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Jesus que me ama tirou-me da lama, \nFez tudo por mim. \nMe deu vida eterna, Jesus me governa \nEu creio assim. \nO crente não cansa, tem essa esperança \nEle vive assim.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O homem reclama quando está na lama \nSem Cristo Jesus. \nSe queres ter sossego, ter vida sem medo, \nAceite a Jesus. \nSó Ele quem salva; Ele deu sua vida \nPara nos remir.',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/jair-pires/estrada-de-espinhos/',
      ),
      Hino(
        codigo: 419,
        titulo: 'ESTOU MARCHANDO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Estou marchando com alegria para a glória \nAleluia! Aleluia! \nAleluia! Cantarei na linda da terra \nAleluia! Aleluia!',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Aleluia! Cantarei na linda terra, \nCom Jesus meu grande Salvador \nEstarei pra sempre livre deste mundo \nNa presença de meu querido Senhor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu desejo é ver de perto a linda terra \nAleluia! Aleluia! \nA cidade preparada para os salvos, \nAleluia! Aleluia!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Lá somente estarão os remidos, \nAleluia! Aleluia! \nPelo sangue glorioso do cordeiro, \nAleluia! Aleluia!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'O ditoso dia já está chegando, \nAleluia! Aleluia! \nEm que Cristo levará a sua igreja, \nAleluia! Aleluia!',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Meu irmão tu te preparas desde agora, \nAleluia! Aleluia! \nPra cantar, comigo, o hino da vitória, \nAleluia! Aleluia!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 420,
        titulo: 'CLAMOR DE DEUS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Oh! Grande Deus, aqui estou, \nCom minha voz, clamando a Ti \nOs dias maus trazem pavor \nTem compaixão, tem compaixão de mim Senhor.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Oh! Grande Deus vem defender-me \nCom Tua mão vem me suster. \nAtende-me, ó Deus de amor \nQue chegue a Ti o meu clamor     (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu sei que a dor vem me assolar \nCom tua mão vem me amparar \nPreciso mais de Ti Senhor \nVem me guiar, vem me amparar com teu amor.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu és meu rei e meu Senhor \nSustenta-me meu Salvador \nClamo com fé, oh! Meu Jesus \nVem me guiar e iluminar com a tua luz.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 421,
        titulo: 'EU CREIO ASSIM',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu creio no Senhor tão grandioso \nQue tem poder para qualquer coisa fazer. \nLevanta o cansado e abatido, \nE faz o fraco a qualquer luta vencer. \nEu leio na Sua Santa Palavra: \nGrandes milagres Ele aqui realizou. \nEu creio que Ele ainda é o mesmo \nÉ poderoso, pois, Jesus jamais mudou.',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu creio assim e assim será \nPois Jesus Cristo não mudou nem mudará   (Bis)',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'A Lázaro restituiu a vida, \nDiante da morte demonstrou o Seu poder, \nA Bartimeu Ele restaurou a vista, \nNo mesmo instante Bartimeu passou a ver. \nAlimentou mulheres e crianças; \nHomens famintos se fartarem Ele fez; \nAndou por sobre o mar encapelado \nOs dez leprosos curou todos de uma vez.',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ressuscitou o filho da viúva; \nO mesmo fez com o servo do Centurião. \nA água Ele transformou em vinho \nE à pecadora Ele deu o seu perdão. \nE aos cegos, surdos, mudos e entrevados, \nCom Seu poder  e Sua bondade Ele os curou; \nE em mim realizou maior milagre \nFoi quando um dia a minha alma Ele salvou.',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 422,
        titulo: 'NAS MÃOS DO OLEIRO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Sou um vaso, sou de barro, \ne o Oleiro, me fez assim \nSou de barro, não de ouro, \nmas tenho um tesouro dentro de mim \nNos momentos de angústias \nou no fogo da provação \nMas o vaso não reclama \ne o Oleiro o toma nas mãos',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Eu sou um vaso nas mãos do Oleiro \nMinha vida por inteiro                      (Bis) \nEstá nas mãos de Jesus \nUsa-me, usa-me',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Quando saio da fornalha \npelo Oleiro sou aprovado \nPois passando pelo fogo \nestou pronto pra ser usado \nSe estou quase desistindo, \nme sentindo um vaso quebrado \nVolto a casa do Oleiro, \nentão, saio de lá renovado',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/eliane-fernandes/sou-um-vaso/',
      ),
      Hino(
        codigo: 423,
        titulo: 'VALOR DE UMA ALMA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmão, você sabe o valor que tem uma alma? \nNem todos os recursos humanos poderiam pagar \nO dinheiro, a prata e o ouro do mundo inteiro \nÉ pouco demais pro valor de uma alma poder comparar',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Irmão, o valor de uma alma custou muito caro \nÉ necessário sentirmos por ela imenso amor \nZelando, ensinando e orando e, às vezes, chorando \nDevemos buscar todas as almas que Jesus comprou',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmão, quantas vezes tem alma ao teu lado chorando? \nSofrendo, gemendo com o fardo pesado de dor? \nSe ela chegar perecer, você é o culpado \nTenhas cuidado, porque uma alma tem muito valor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Irmão, você lembra do ide do Mestre amado? \nNão foi um pedido, mas ordem que Ele nos deu \nComo podemos ficar com os braços cruzados \nSe Ele, de braços abertos, por todos morreu?',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/mara-lima/valor-de-uma-alma/',
      ),
      Hino(
        codigo: 424,
        titulo: 'CRISTO CAMINHAVA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Cristo caminhava lentamente \nPasso a passo com decisão \nDe repente ele bradou: Alguém tocou-me \nAlguém no meio da multidão \nMestre a multidão te oprime \nDe todos os lados assim \nCristo disse: Alguém tocou-me diferente \nPois eu senti, saiu virtude de mim ',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Toca pela fé agora em Jesus \nPois, ele vai te conceder a luz \nEstende a mão, Jesus vai te tocar \nToca pela fé, agora é só pedir \nQue de Jesus virtude vai sair \nEstende as mãos Jesus vai te tocar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Então uma mulher aproximou-se \nE disse: Foi eu Senhor que te tocou \nCristo então, falou-lhe mui suavemente \nVai em paz, a tua fé te salvou \nSe queres a alegria em tua vida \nSe queres a vitória em teu lar \nSinta agora a morte transforma-se em vida \nQuando a mão de Deus te tocar',
          ),
        ],
        urlCifraSite:
        'https://www.cifraclub.com.br/mara-lima/cristo-caminhava-lentamente/',
      ),
      Hino(
        codigo: 425,
        titulo: 'JESUS CRISTO TE ESTENDE A MÃO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se tu procuras encontrar a bênção \nE ainda não pudeste encontrar \nFique sabendo que Jesus te ama \nMais do que nunca quer te abençoar \nSe tu ficares no altar de Cristo \nCom tua vida em santificação \nTu hoje mesmo vais levar a bênção \nPorque Jesus Cristo te estende as mãos ',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Cristo Estende a mão, Cristo estende a mão \nO crente que ora pode ver agora \nCristo estende a mão, Cristo estende a mão \nPosso ver até com os olhos da fé \nCristo estendendo a mão',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Não adianta procurar a bênção \nEm um lugar que não podes achar \nPorque meu Deus não é brincadeira \nNão é usado gosta de usar \nEle exige uma fé sincera \nUma certeza uma convicção \nSe tens pedido algo a Jesus Cristo \nPodes ficar certo Ele estende as mãos',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tu hoje mesmo vais levar a bênção \nQue tens pedido sempre em oração \nPorque meu Deus não tem olhos vendados \nNem seus ouvidos agravados são \nAs suas mãos estão sempre estendidas \nCom bênçãos para cada coração \nSe realmente és crente de fé \nCante então comigo Cristo estende a mão!',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 426,
        titulo: 'VENHA AS ÁGUAS',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'No deserto desta vida em completa sequidão \nTriste está a tua vida e também teu coração \nMas contemplará na frente, da montanha existe paz \nOnde manam águas vivas em profundos mananciais',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Venha as águas, se você está com sede vem beber \nVenha as águas, águas vivas que Jesus tem pra você',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Se você está sofrendo tem um tanque em Siloé \nOnde Deus visita as águas e contempla a sua fé \nEsta água é milagrosa, esta água tem poder \nVenha logo a estas águas que Jesus tem pra você',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Tem um cântaro na fonte à tua disposição \nEste cântaro está ao alcance de tua mão \nEsta água é milagrosa, a palavra é fiel \nEsta água vem da fonte e a fonte está no céu',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Venha as águas, se você está com sede vem beber \nVenha as águas, águas vivas que Jesus tem pra você',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 427,
        titulo: 'OVELHA PERDIDA',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu sou aquela ovelha que perdida estava \nporque sendo rebelde do aprisco me afastei \nbem longe do pastor sozinha eu caminhava \nno fundo do abismo então me deparei \nali entre os espinhos eu fiquei ferida \nquase desfalecida comecei a chorar \nmas o pastor que é tão meigo e amoroso \ntomando o seu cajado saiu a me procurar',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Minha querida ovelha aonde está você \npor ser tão pequenina deve estar a sofrer \nestou aqui senhor não posso me levantar \nperdoa os meus pecados e venha me ajudar',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Ali entre os espinhos toda machucada \nnão podia mover pois era grande a escuridão \nsentindo muita dor e com a alma angustiada \nsenti que acabava a esperança em meu coração \nmas o pastor amado com todo carinho \ntomando-me em seus braços do abismo me tirou \nlimpando a minha lã e pondo azeite em minhas feridas \ncolocou-me em seus ombros e ao aprisco me levou',
          ),
          TrechoHino(
            tipo: 'negrito',
            texto:
            'Minha querida ovelha eu hoje te encontrei \nnão deixe os meus caminhos eu tanto lhe avisei \nperdoa-me senhor, não vou mais te deixar \neu seguirei seus passos seja em qualquer lugar',
          ),
        ],
        urlCifraSite: '',
      ),
      Hino(
        codigo: 428,
        titulo: 'LIVRO BENDITO',
        trechos: [
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu tenho, um livro bendito \nOnde está escrito que Deus é amor \nEu tenho um livro que fala \nQue a fé não se abala \nEm cristo, o Senhor \nEu tenho um livro precioso \nPois é tão glorioso senti-lo assim \nFala da santa promessa \nDa vitória certa que hei de fluir',
          ),
          TrechoHino(
            tipo: 'refrao',
            texto:
            'Bíblia tu és, o meu livro \nDe mui terno amor \nBíblia tu és e serás. \nSempre o meu condutor',
          ),
          TrechoHino(
            tipo: 'estrofe',
            texto:
            'Eu tenho um livro bendito \nQue fala do Cristo pregado na cruz \nDe paulo em sua jornada \nDepois de sentir em si uma luz \nEu tenho um livro que fala \nDo cego liberto lá em jerico \nFala que entre os amigos \nAqui desse mundo \nJesus é o melhor',
          ),
        ],
        urlCifraSite: '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hinário')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _pesquisaController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Pesquisar por código, título ou trecho',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filtrarHinos,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: hinosFiltrados.length,
              itemBuilder: (context, index) {
                final hino = hinosFiltrados[index];
                return ListTile(
                  leading: Icon(Icons.queue_music, color: Color(0xFF2CA59A)),
                  title: Text('${hino.codigo} - ${hino.titulo}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LetraHinoScreen(hino: hino),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LetraHinoScreen extends StatefulWidget {
  final Hino hino;

  LetraHinoScreen({required this.hino});

  @override
  _LetraHinoScreenState createState() => _LetraHinoScreenState();
}

class _LetraHinoScreenState extends State<LetraHinoScreen> {
  double fontSize = 16;

  void abrirSite() async {
    final url = widget.hino.urlCifraSite;
    final sucesso = await launchUrlString(url);
    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o site da cifra.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> trechosWidgets = [];

    int estrofeCount = 1;
    for (var trecho in widget.hino.trechos) {
      Widget textoWidget;
      switch (trecho.tipo) {
        case 'estrofe':
          textoWidget = Text(
            '$estrofeCount \n${trecho.texto}',
            style: TextStyle(fontSize: fontSize, color: Colors.black),
          );
          estrofeCount++;
          break;
        case 'refrao':
          textoWidget = Padding(
            padding: EdgeInsets.only(left: fontSize * 0.6 * 2),
            child: Text(
              trecho.texto,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
          break;
        case 'negrito':
          textoWidget = Padding(
            padding: EdgeInsets.only(left: fontSize * 0.6 * 2),
            child: Text(
              trecho.texto,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
          break;
        default:
          textoWidget = Text(
            trecho.texto,
            style: TextStyle(fontSize: fontSize),
          );
      }
      trechosWidgets.add(
        Padding(padding: EdgeInsets.only(bottom: 12), child: textoWidget),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hino.codigo} - ${widget.hino.titulo}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: trechosWidgets,
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => setState(() => fontSize += 2),
                  icon: Icon(Icons.zoom_in, color: Color(0xFF2CA59A)),
                  tooltip: 'Aumentar fonte',
                ),
                IconButton(
                  onPressed: () =>
                      setState(() {
                        fontSize = fontSize > 10 ? fontSize - 2 : fontSize;
                      }),
                  icon: Icon(Icons.zoom_out, color: Color(0xFF2CA59A)),
                  tooltip: 'Diminuir fonte',
                ),
                ElevatedButton.icon(
                  onPressed: abrirSite,
                  icon: Icon(Icons.language),
                  label: Text('Cifra Site'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CredenciaisScreen extends StatefulWidget {
  @override
  _CredenciaisScreenState createState() => _CredenciaisScreenState();
}

class _CredenciaisScreenState extends State<CredenciaisScreen> {
  final TextEditingController _senhaController = TextEditingController();
  String? caminhoImagemCredencial;
  bool credencialLiberada = false;

  final String whatsappSecretario = '+5562991072423';

  Future<bool> imagemExiste(String caminho) async {
    try {
      await rootBundle.load(caminho);
      return true;
    } catch (_) {
      return false;
    }
  }

  void verificarSenha() async {
    final senha = _senhaController.text.trim().toUpperCase();
    final caminho = 'assets/credenciais/$senha.png';

    final existe = await imagemExiste(caminho);
    if (existe) {
      setState(() {
        caminhoImagemCredencial = caminho;
        credencialLiberada = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Credencial não encontrada. Verifique a senha.'),
        ),
      );
    }
  }

  void abrirWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$whatsappSecretario?text=A paz do Senhor, gostaria de solicitar minha credencial.',
    );
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6F0FA),
      appBar: AppBar(title: Text('Credenciais')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A senha será as iniciais do nome e os 6 primeiros dígitos do CPF, exemplo: '
                    '\nManoel Joaquim Alves da Silva, CPF 224.658.998-70, '
                    '\nentão a senha seria MJAS224658',
                style: TextStyle(fontSize: 16, color: Color(0xFF002D72)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Text(
                'Informe sua senha para visualizar a credencial:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002D72),
                ),
              ),

              SizedBox(height: 12),
              TextField(
                style: TextStyle(color: Colors.black),
                controller: _senhaController,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                obscureText: true,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: verificarSenha,
                  icon: Icon(Icons.lock_open, color: Colors.black),
                  label: Text('Verificar Senha'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (credencialLiberada && caminhoImagemCredencial != null)
                Column(
                  children: [
                    Text(
                      'Credencial:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002D72),
                      ),
                    ),
                    SizedBox(height: 12),
                    Image.asset(caminhoImagemCredencial!),
                  ],
                ),
              SizedBox(height: 30),
              Text(
                'Ainda não tem sua credencial?',
                style: TextStyle(fontSize: 16, color: Color(0xFF002D72)),
              ),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: abrirWhatsApp,
                  icon: Icon(Icons.chat, color: Colors.white),
                  label: Text('Solicitar credencial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2CA59A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CapituloEtica {
  final String tituloEtica;
  final String conteudoEtica;

  CapituloEtica({required this.tituloEtica, required this.conteudoEtica});

  String get tituloCompleto => '$tituloEtica';
}

class CodigoEticaScreen extends StatelessWidget {
  final List<CapituloEtica> capitulos = [
    CapituloEtica(
      tituloEtica: 'PREÂMBULO',
      conteudoEtica:
      'A IGREJA CRISTÃ EVANGÉLICA DO AVIVAMENTO - ICEA - visando a grandeza e unidade '
          'ministerial entre os seus obreiros, estabelece este "Código de Ética", que deverá ser observado com'
          ' idoneidade, humildade, amor e obediência. \n O obreiro que colocar em prática o disposto neste '
          'Código, sem dúvida, seu ministério será mais produtivo, não terá de que se envergonhar e receberá '
          'a aprovação do povo e de Deus. \n',
    ),
    CapituloEtica(
      tituloEtica: 'NA IGREJA',
      conteudoEtica:
      'Art. 1º - O obreiro deve ter uma permanente comunhão com o Senhor Jesus Cristo, '
          'por meio da oração e do estudo da Bíblia.\n \n Art. 2º - Sempre que for possível, aprofundar-se'
          ' nos conhecimentos teológicos e da cultura geral. \n \n Art. 3º - O obreiro precisa compreender,'
          ' amar, respeitar e tratar com humanidade os problemas dos membros da igreja onde frequenta. \n '
          '\n Art. 4º - O obreiro deve se comportar com discrição em todos os sentidos, não expondo a '
          'público, assuntos confidenciais, como ilustração de mensagens ou de conversas particulares, '
          'afim de não trazer transtorno entre o confidente e a pessoa envolvida. \n \n Art. 5º - O obreiro'
          ' não deve trazer a público, assuntos do gabinete pastoral; se, porventura, acontecer, que não '
          'seja assunto confidencial e não cite nomes. \n \n Art. 6º - O gabinete pastoral deve ter um visor'
          ' de vidro, quanto maior melhor, para evitar censura. \n \n Art. 7º - O obreiro é o líder da '
          'igreja e não o ditador; isso significa que a sua palavra e posicionamento não devem prevalecer;'
          ' o povo também tem ideias, palavras e posicionamentos corretos. \n \n Art. 8º - O obreiro não '
          'deve, em nenhuma hipótese, se envolver com grupos no seio da igreja que, com palavras frívolas,'
          ' vivem criando problemas; quando for resolvê- ..... \n \n Art. 9º - O obreiro deve ser coerente'
          ' entre práticas e/ou atos litúrgicos, com doutrinas dignas de respectivas fundamentações bíblicas.'
          '\n \n Art. 10º - O obreiro não deve discutir com membros de igreja, principalmente, em público. \n'
          ' \n Art. 11º - O obreiro, ao visitar os lares, deve portar-se discretamente, com absoluto '
          'respeito, dignidade e, sempre que possível, em companhia da esposa. \n \n Art. 12º - O obreiro, '
          'ao visitar um lar, se estiver só mulher, é melhor não entrar, se houver insistência por parte '
          'dela, deve manter a porta de entrada aberta, se assentar junto ou de frente para a porta, afim '
          'de ser visto por todos que transitarem pelas imediações e evitar assuntos íntimos relacionados a'
          ' sexo e outros. Deve ser uma visita rápida. \n',
    ),
    CapituloEtica(
      tituloEtica: 'NO LAR',
      conteudoEtica:
      'Art. 13º - O obreiro deve ter e demonstrar uma convivência sadia, amorosa e '
          'respeitosa com sua família.\n \n Art. 14º - O obreiro deve tratar a esposa, particular e '
          'publicamente, com carinho, respeito e companheirismo, em todas as ocasiões. \n \n Art. 15º '
          '- O obreiro deve disciplinar os filhos no temor do Senhor, evitando corrigi-los em público. '
          '\n \n Art. 16º - O obreiro, coadjuvado com a esposa, deve orientar os filhos, quanto aos '
          'acontecimentos atuais, para que possam discernir as coisas que não convem a um cristão. \n '
          '\n Art. 17º -O obreiro deve separar parte do seu tempo para dedicar-se ao lazer com a família.'
          ' \n \n Art. 18º - O obreiro deve manter a sua família, financeiramente, dentro de suas '
          'possibilidades sem envolver-se em dívida.\n \n Art. 19º - O obreiro não deve, em nenhum '
          'momento, discutir ou comentar discussões com a família, junto a pessoas estranhas à mesma. \n',
    ),
    CapituloEtica(
      tituloEtica: 'NA SOCIEDADE',
      conteudoEtica:
      'Art. 20º - O obreiro deve primar por uma conduta irrepreensível perante a sociedade.'
          ' \n \n Art. 21º - O obreiro deve se comportar com sinceridade, honestidade, boa moral, '
          'pontualidade nos negócios e obrigações, uma só palavra. \n \n Art. 22º - O obreiro não deve '
          'contrair dívidas, além das suas possibilidades de ganho. \n \n Art. 23º - O obreiro deve amar '
          'e respeitar a Pátria, observar as suas leis e influenciar outros a faze-lo. \n \n Art. 24º - O'
          ' obreiro, em seu local de trabalho secular, não deve criar qualquer situação que cause '
          'transtorno junto aos seus superiores ou colegas. \n',
    ),
    CapituloEtica(
      tituloEtica: 'ENTRE COLEGAS',
      conteudoEtica:
      'Art. 25º - O obreiro não deve fazer e nem aceitar comentários desabonadores a '
          'respeito de seu colega de ministério. \n \n Art. 26º - O obreiro deve evitar fazer e aceitar '
          'propaganda negativa, com relação a pessoa ou família de seu colega de ministério. \n \n Art. '
          '27º - O obreiro, ao citar frases ou ilustrações que não sejam suas necessariamente precisa citar'
          ' a fonte. \n \n Art. 28º - O obreiro, ao ouvir um colega reclamar de outro, confidencialmente,'
          ' para si, não deve comentar o assunto com ninguém, para evitar atritos e mal entendidos. \n \n '
          'Art. 29º - O obreiro, ao suceder o colega na igreja, nunca deve desmerecer o trabalho do seu '
          'antecessor, ainda que não tenha sido dos melhores. \n \n Art. 30º - O obreiro deve ser amigo de'
          ' seu colega de ministério, bem como, da família, deixando patente ser o elemento de confiança do'
          ' colega. \n \n Art. 31º - O obreiro deve evitar comentar com o colega, assuntos desagradáveis '
          'comentados em reuniões de convenção ou de conselho, junto a membros de igreja, esposa e filhos. \n',
    ),
    CapituloEtica(
      tituloEtica: 'ENTRE IGREJAS',
      conteudoEtica:
      'Art. 32º - O obreiro não deve interferir em questões surgidas em igrejas que não '
          'estão sob a sua jurisdição, a não ser que seja solicitado pelo titular do rebanho. \n \n Art. '
          '33º - O obreiro só deve pregar numa igreja, que não esteja sob seu pastoreio, após ter a '
          'aquiescência do Pastor titular.\n \n Art. 34º - O obreiro deve respeitar a contribuição '
          'doutrinária de cada denominação, ainda que com ela não concorde. \n \n Art. 35º - O obreiro deve'
          ' ganhar vidas para o reino de Deus e não praticar o proselitismo. \n \n Art. 36º - O obreiro, ao'
          ' ser convidado para pregar em igrejas de outras denominações, ao aceitar, deve respeitar a sua '
          'doutrina e costumes, não criticando-a na mensagem. \n \n Art. 37º - O obreiro não deve usar o '
          'púlpito de sua igreja como de outras para atacar quem quer que seja; o púlpito é para entregar '
          'o recado de Deus. \n ',
    ),
    CapituloEtica(
      tituloEtica: 'DISPOSIÇÃO GERAL E FINAL',
      conteudoEtica:
      'Art. 38º - O obreiro que infrigir este Código de Ética está sujeito a disciplina, '
          'após ser encaminhado à comissão de campo da ICEA, através de seu presidente. \n \n Art. 39º - '
          'Revogam-se as disposições em contrário. ',
    ),
  ];

  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulIntermediario,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Código de Ética'),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: capitulos.length,
        itemBuilder: (context, index) {
          final capitulo = capitulos[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            decoration: BoxDecoration(
              color: azulIntermediario,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              leading: Icon(Icons.check_circle, color: dourado),
              title: Text(
                capitulo.tituloCompleto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetalheEticaScreen(capitulos: capitulos, index: index),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetalheEticaScreen extends StatefulWidget {
  final List<CapituloEtica> capitulos;
  final int index;

  DetalheEticaScreen({required this.capitulos, required this.index});

  @override
  _DetalheEticaScreenState createState() => _DetalheEticaScreenState();
}

class _DetalheEticaScreenState extends State<DetalheEticaScreen> {
  double fontSize = 16;

  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFFFFD700);

  void abrirCapitulo(int index) {
    if (index >= 0 && index < widget.capitulos.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetalheEticaScreen(capitulos: widget.capitulos, index: index),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final capitulo = widget.capitulos[widget.index];
    return Scaffold(
      backgroundColor: azulClaro,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          capitulo.tituloCompleto,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                capitulo.conteudoEtica,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.index > 0
                      ? () => abrirCapitulo(widget.index - 1)
                      : null,
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  label: Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dourado,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.index < widget.capitulos.length - 1
                      ? () => abrirCapitulo(widget.index + 1)
                      : null,
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                  label: Text('Próximo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dourado,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => fontSize += 2),
                  icon: Icon(Icons.zoom_in, color: azulProfundo),
                  tooltip: "Aumentar Fonte",
                ),
                IconButton(
                  onPressed: () =>
                      setState(() {
                        fontSize = fontSize > 10 ? fontSize - 2 : fontSize;
                      }),
                  icon: Icon(Icons.zoom_out, color: azulProfundo),
                  tooltip: "Diminuir Fonte",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CapituloRegimento {
  final String titulo;
  final String subtitulo;
  final String conteudo;

  CapituloRegimento({
    required this.titulo,
    required this.subtitulo,
    required this.conteudo,
  });

  String get tituloCompleto => '$titulo\n$subtitulo';
}

class RegimentoScreen extends StatefulWidget {
  @override
  _RegimentoScreenState createState() => _RegimentoScreenState();
}

class _RegimentoScreenState extends State<RegimentoScreen> {
  late ScrollController scrollController;

  final List<CapituloRegimento> capitulos = [
    CapituloRegimento(
      titulo: 'Capítulo I',
      subtitulo: 'DE DENOMINAÇÃO, DOS FINS E DA SEDE',
      conteudo:
      'Art. 1º - A \"IGREJA CRISTÃ EVANGÉLICA DO AVIVAMENTO\" - ICEA, MINISTÉRIO DE ANÁPOLIS, doravante designada neste'
          ' Estatuto apenas \'ICEA\', fundada em 24 de março de 1990, conforme Ata nº 01, do Livro de Atas nº 01, com data de '
          'registro no Cartório de Registro de Títulos e Documentos e de Pessoas Jurídicas de Anápolis/Go, em 20 de novembro de 1992,'
          ' cujos fundadores restam devidamente apontados na referida ata de fundação e que tem, como integrantes do CONSELHO '
          'ADMINISTRATIVO e do CONSELHO FISCAL as pessoas descriminadas na ata ora apresentada conjuntamente para registro, é pessoa'
          ' jurídica de direito privado, constituída sob a forma de Entidade Religiosa, sem fins lucrativos, constituída por tempo '
          'indeterminado, com sede em Anápolis, estado de Goiás, na Rua Pablo, Quadra 66, Lote 17, CEP 75.114-740,e será regida pelo'
          ' presente.\n \n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo II',
      subtitulo: 'DA ADMINISTRAÇÃO',
      conteudo:
      'Art. 2º - São órgãos administrativos da Igreja:\n I - Assembléia Geral - Normativo e Deliberativo.\n II - Conselho '
          'Administrativo - Administrativo e Executivo.\n \n Art. 3º - A Assembléia Geral é formada por todos os Membros Especiais, '
          'Regulares e Membros elegíveis.\n \n Art. 4º - Atribuições do Conselho Administrativo - As constantes no Estatuto.\n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo III',
      subtitulo: 'DA RESPONSABILIDADE PARA COM SEUS FILIADOS',
      conteudo:
      'Art. 5º - As responsabilidades da \'ICEA\' para com seus filiados são:\n I - Separar, consagrar e ordenar Obreiros;\n '
          'II - Promover reuniões, retiros, encontros de confraternização entre os filiados;\n III - Realizar culto fúnebre, quando '
          'pedido pelo membro em vida, ou pela família.\n \n § 1º - As consagrações de Obreiros serão realizadas em um culto solene, '
          'com imposição de mãos e unção com azeite.\n \n § 2º - Só serão separados, consagrados a Obreiros, ou candidatos ao ministério,'
          ' pessoas já incluídas como membros regulares ou elegíveis.\n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo IV',
      subtitulo: 'DOS OBREIROS',
      conteudo:
      'Do Pastor\n Art. 6º - O Pastor é um homem vocacionado, para ensinar a palavra de Deus.\n \n Art. 7º - Funções do Pastor:'
          '\n I - As descritas no Estatuto;\n II - Administrar a Igreja;\n III - Outras funções atinentes ao Cargo.\n \n Parágrafo Único -'
          ' Para ser consagrado a Pastor, é necessário que o candidato tenha rebanho, e seja membro elegível.\n \n Art. 8º - É vedado ao'
          ' Pastor:\n I - Ministrar qualquer ensino que contrarie a Bíblia;\n II - Todos os itens previstos no Art. 50º do Estatuto.\n \n'
          ' \n Do Evangelista\n Art. 9º - O Evangelista é um homem vocacionado por Deus, com qualidades evangelísticas, podendo em caso de'
          ' necessidade ministrar atos pastorais.\n \n Art. 10º - Funções do Evangelista:\n I - Desempenhar como prioridade a obra '
          'evangelística.\n \n \n Do Presbítero\n Art. 11º - O Presbítero é um homem vocacionado por Deus para auxiliar no governo e '
          'pastorado da Igreja. Tm 5:17.\n \n Art. 12º - Funções e responsabilidades do Presbítero:\n I - Ungir com óleo os doentes. '
          'Tg 5:13-16.\n II - Assumir Congregações.\n III - Realizar atos pastorais quando designado pelo Conselho Administrativo.\n IV '
          '- Ser assíduo e pontual nos trabalhos da Igreja.\n V - Substituir o Pastor, quando necessário.\n \n \n Da Missionária\n Art. 13º'
          ' - A Missionária é a mulher vocacionada por Deus, para o desempenho da sua obra, apta para ensinar, com qualidades ministeriais.'
          '\n \n Parágrafo Único - A Missionária por ter e desempenhar funções espirituais, poderá a seu critério tomar assento no Púlpito '
          'das Igrejas da \'ICEA\'.\n \n Art. 14º - Funções e responsabilidades da Missionária:\n I - Realizar a obra evangelística.\n II -'
          ' Ministrar mensagens e estudos bíblicos.\n III - Visitar, acomnselhar, os Membros e orar pelos enfermos.\n IV - Ministrar '
          'louvores, ensaios, quando for vocacionada.\n V - Ministrar unção com óleo, quando for delegada por um Pastor.\n VI - Na falta de'
          ' Pastores, Presbíteros, quando delegada pelo Conselho Administrativo, assumir Congregações.\n \n \n Do Diácono e Diaconisa\n Art.'
          ' 15º - O Diácono e a Diaconisa são homens e mulheres, agraciados por Deus, que se destacam nos cuidados para com os bens '
          'materiais da Igreja.\n \n Art. 16º - Funções do Diácono e da Diaconisa:\n I - Desempenhar a Obra Social.\n II - Cuidar dos órfãos'
          ' e das viúvas.\n III - Visitar e assistir enfermos.\n IV - Zelar pela ordem durante os cultos, e atos religiosos dentro e fora do'
          ' templo.\n V - Abrir e fechar o Templo, para realização dos cultos.\n VI - Recepcionar na parte da entrada todos que ali chegarem.'
          '\n VII - Auxiliar na ministração de Santa Ceia e Batismo.\n \n Art. 17º - É assegurado aos obreiros o direito de licenciar-se '
          'pelo período de 12 (doze) meses de suas funções, permanecendo como membro e em comunhão.\n \n Art. 18º - Os Obreiros, nos '
          'trabalhos públicos da Igreja e nas reuniões ministeriais, apresentar-se-ão socialmente acrescentado da gravata.\n \n Parágrafo '
          'Único - A \'ICEA\', reconhece o divórcio para os integrantes do Conselho Espiritual, quando por infidelidade conjugal ou quando '
          'acontecido antes da conversão. Mt 5:32 e II Co 5:17.\n\n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo V',
      subtitulo: 'DOS MEMBROS',
      conteudo:
      'Art. 19º - Os Membros são admitidos de acordo com o Estatuto.\n \n Parágrafo Único - A disciplina do membro será aplicada'
          ' em conformidade com o previsto no Estatuto.\n \n Art. 20º - O Batismo aceito pela \'ICEA\' é por imersão, em nome do Pai, do '
          'Filho e do Espírito Santo. Mt 28:19 e Mc 16:16.\n \n Art. 21º - Para ser membro, a pessoa precisa aceitar o Estatuto, Regimento'
          ' Interno e assinar Termo de Concordância.\n \n Art. 22º - O membro é livre para pedir a sua demissão, dentro de um clima '
          'amigável.\n \n Art. 23º - Deveres dos membros:\n I - Ter uma vida santificada. I Ts 4:3.\n II - Obedecer e honrar os Obreiros da'
          ' Igreja. Hb 13:17 e I Tm 5:17.\n III - Abster-se de negócios que envolvam engano e furto. I Tm 3:13.\n IV - Contribuir '
          'regularmente com os dízimos e ofertas. Ml 3:8-10 e Mt 23:23.\n V - Ser assíduo às reuniões da Igreja. Hb 10:25.\n VI - Pertencer'
          ' a um Departamento interno da Igreja.\n VII - Não contrair núpcias com descrentes, desviados, sob pena de não ter o apoio da '
          'Igreja, Ministração Pastoral, inclusive o empréstimo do Templo. II Co 6:14-15.\n VIII - Saldar os compromissos financeiros '
          'assumidos dentro e fora da Igreja. Rm 13:7-8.\n IX - O membro masculino, não deve usar, cabelo crescido, I Co 11:4,7 e 14, '
          'brincos, pirsing ou jóias que tenha semelhança das usadas pelo sexo feminimo. I Pe 3:3.\n X - Quanto a vestimenta, os membros '
          'devem privar-se pelo princípio da diferença homem e mulher, trajando decentemente conforme a palavra de Deus. Dt 22:5, I Tm 2:9 '
          'e I Pe 3:3.\n XI - O membro feminino deve conservar o seu cabelo crescido. I Co 11:5, 6, 14 e 15.\n XII - O membro feminino não '
          'deve usar jóias extravagantes, exageradas, pirsing em nenhum parte do corpo. I Pe 3:3.\n XIII - Evitar a aparência do mal. '
          'I Ts 5:22.\n \n Parágrafo Único - A \'ICEA\' posiciona-se como vestes indecentes para o seus membros, os seguintes trajes: '
          'shorts, saias e calças coladas, mini-saias, blusas curtas ou de alças finas.\n \n Art. 24º - O membro na prática de atividades '
          'físicas, esportivas, caminhadas, para o bem estar do corpo, poderá usar vestes adequadas.\n \n Art. 25º - No cumprimento de '
          'Normas profissionais, escolares e estatutos militares o membro poderá usar os uniformes exigidos.\n \n \n Do Auxiliar\n Art. 26º'
          ' - O Membro, para ser indicado a auxiliar, deve ser membro regular, encaminhado ao Conselho Administrativo pelo seu Pastor, ser '
          'examinado quanto a sua vocação, colocado em prova pelo período mínimo de 06 (seis) meses.\n \n Art. 27º - O Auxiliar não assumirá,'
          ' púlpito, mas ficará a disposição para atender qualquer eventualidade durante o serviço religioso.\n\n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo VI',
      subtitulo: 'DA SEDE E CONGREGAÇÕES',
      conteudo:
      'Art. 28º - As Congregações fecharão seus respectivos caixas financeiros mensalmente, todo dia 09 (nove), e enviará para o'
          ' caixa da Igreja Sede, 22% (vinte e dois por cento) de sua entrada, bruta para manutenção do Campo.\n \n Art. 29º - A Igreja Sede'
          ' deve manter atualizada a sua contabilidade.\n \n Art. 30º - Os Obreiros efetuarão o pagamento de uma taxa de 10% (dez por cento)'
          ' do Salário Mínimo vigente a título de anuidade, sempre na 1ª reunião do Conselho Administrativo, data em que será criada e '
          'aprovada a agenda anual de trabalhos e programações Espirituais do ano ou na sua filiação.\n \n Parágrafo Único - A taxa de '
          'anuidade dos obreiros será dividida em partes iguais para a secretaria e seu respectivo departamento.\n\n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo VII',
      subtitulo: 'DOS MEMBROS COM DONS ESPIRITUAIS',
      conteudo:
      'Art. 31º - A \'ICEA\' aceita os dons espirituais como dádiva de Deus aos membros, para ajudar a condunzi-la a igreja nos'
          ' dias atuais.\n \n Art. 32º - As mensagens recebidas através dos dons espirituais, devem ser entregues, primeiramente, ao Pastor'
          ' da Igreja, com exceção da profecia.\n',
    ),
    CapituloRegimento(
      titulo: 'Capítulo VIII',
      subtitulo: 'DISPOSIÇÕES GERAIS',
      conteudo:
      'Art. 33º - A \'ICEA\', subdivide interinamente em Departamentos; Departamento de Varões, Departamento de Senhoras (União'
          ' Auxiliadora Feminina), Departamento de Mocidade, e Departamento de Escola Bíblica Dominical.\n \n Parágrafo Único - Todo crente'
          ' ao ser recebido como membro da Igreja e do Corpo de Cristo, será encaminhado à Diretoria de seu departamento, onde servirá a '
          'Deus, sob orientações, normas e trabalhos criados no respectivo Departamento.\n \n Art. 34º - O Obreiro dirigente de '
          'Congregações, não poderá resistir as decisões do Pastor Presidente ou do Conselho Administrativo, sob pena de ser recolhido à'
          ' Igreja sede e ficar em disponibilidade.\n \n Art. 35º - O Pastor Presidente e os dirigentes de Congregações tem a incumbência'
          ' de cuidar da aparência do tempo, pintura, letreiro que identifique a Igreja, a pintura e letreiros devem ser feitos por '
          'profissionais do ramo.\n \n Art. 36º - Os casos omissos neste Regimento Interno serão examinados à luz da Bíblia que, lançados'
          ' em ata, terão força estatutária.\n \n Art. 37º - Este Regimento Interno entra em vigor na data de sua aprovação pela Assembléia'
          ' Geral.\n \n Art. 38º - Revogam-se as disposições em contrário.\n\n',
    ),
  ];

  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulIntermediario,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Regimento'),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: capitulos.length,
        itemBuilder: (context, index) {
          final capitulo = capitulos[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            decoration: BoxDecoration(
              color: azulIntermediario,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              leading: Icon(Icons.library_books, color: dourado),
              title: Text(
                capitulo.tituloCompleto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RegimentoDetalheScreen(
                          capituloRegimento: capitulos[index],
                          indexRegimento: index,
                          capitulosRegimento: capitulos,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RegimentoDetalheScreen extends StatefulWidget {
  final CapituloRegimento capituloRegimento;
  final int indexRegimento;
  final List<CapituloRegimento> capitulosRegimento;

  RegimentoDetalheScreen({
    required this.capituloRegimento,
    required this.indexRegimento,
    required this.capitulosRegimento,
  });

  @override
  _RegimentoDetalheScreenState createState() => _RegimentoDetalheScreenState();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          capituloRegimento.tituloCompleto,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          capituloRegimento.conteudo,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}

class _RegimentoDetalheScreenState extends State<RegimentoDetalheScreen> {
  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);
  double fontSize = 16;

  void abrirCapitulo(int novoIndex) {
    if (novoIndex >= 0 && novoIndex < widget.capitulosRegimento.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RegimentoDetalheScreen(
                capituloRegimento: widget.capitulosRegimento[novoIndex],
                indexRegimento: novoIndex,
                capitulosRegimento: widget.capitulosRegimento,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulClaro,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.capituloRegimento.tituloCompleto,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                widget.capituloRegimento.conteudo,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.indexRegimento > 0
                      ? () => abrirCapitulo(widget.indexRegimento - 1)
                      : null,
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  label: Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dourado,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                  widget.indexRegimento <
                      widget.capitulosRegimento.length - 1
                      ? () => abrirCapitulo(widget.indexRegimento + 1)
                      : null,
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                  label: Text('Próximo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dourado,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => fontSize += 2),
                  icon: Icon(Icons.zoom_in, color: azulProfundo),
                  tooltip: 'Aumentar fonte',
                ),
                IconButton(
                  onPressed: () =>
                      setState(
                            () =>
                        fontSize = fontSize > 10 ? fontSize - 2 : fontSize,
                      ),
                  icon: Icon(Icons.zoom_out, color: azulProfundo),
                  tooltip: 'Diminuir fonte',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CapituloEstatuto {
  final String titulo;
  final String subtitulo;
  final String conteudo;
  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  CapituloEstatuto({
    required this.titulo,
    required this.subtitulo,
    required this.conteudo,
  });

  String get tituloCompleto => '$titulo\n$subtitulo';
}

class EstatutoScreen extends StatefulWidget {
  @override
  _EstatutoScreenState createState() => _EstatutoScreenState();
}

class _EstatutoScreenState extends State<EstatutoScreen> {
  late ScrollController scrollController;

  final List<CapituloEstatuto> capitulos = [
    CapituloEstatuto(
      titulo: 'Apresentação',
      subtitulo: '',
      conteudo:
      '\"A IGREJA CRISTÃ EVANGÉLICA DO AVIVAMENTO - ICEA\", MINISTÉRIO DE ANÁPOLIS, inscrita no CNPJ sob nº '
          '36.966.057/0001-59, com sede na Rua Pablo, Quadra 66-B, Lote 17, Bairro JK Nova Capital, na cidade de Anápolis/Go, CEP 75.114-740, '
          'cujo Estatuto Social encontra-se inscrito no Livro 06, do 2º Cartório de Registro de Títulos e Documentos e de Pessoas Jurídicas da'
          'Comarca de Anápolis/Go, sob nº 21.829, de 20/11/1992, apontado sob o Protocolo nº 669, altera seu ESTATUTO SOCIAL que passará a viger'
          'nos seguintes termos, imediatamente após ser registrado:',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo I',
      subtitulo: 'DE DENOMINAÇÃO, DOS FINS E DA SEDE',
      conteudo:
      'Art. 1º - A \"IGREJA CRISTÃ EVANGÉLICA DO AVIVAMENTO - ICEA\", MINISTÉRIO DE ANÁPOLIS, doravante designada neste Estatuto apenas'
          ' \'ICEA\', fundada em 24 de março de 1990, conforme Ata nº 01, do Livro de Atas nº 01, com data de registro no Cartório de Registro de '
          'Títulos e Documentos e de Pessoas Jurídicas de Anápolis/Go, em 20 de novembro de 1992, cujos fundadores restam devidamente apontados na '
          'referida ata de fundação e que tem, como integrantes do CONSELHO ADMINISTRATIVO e do CONSELHO FISCAL as pessoas descriminadas na ata ora '
          'apresentada conjuntamente para registro, é pessoa jurídica de direito privado, constituída sob a forma de Entidade Religiosa, filantrópica '
          'sem fins lucrativos, constituída por tempo indeterminado, com sede em Anápolis, estado de Goiás, na Rua Pablo, Quadra 66, Lote 17, '
          'CEP 75.114-740,e será regida pelo presente Estatuto\n \n § 1º - A \'ICEA\' reconhece somente a Jesus Cristo como seu único cabeça, e '
          'suprema autoridade espiritual, no que tem para regência deste seu governo a Bíblia Sagrada; assim, neste seu governo espiritual e no '
          'cumprimento de sua finalidade de cultuar a Deus, aplicar recursos e esforços na evangelização, desenvolver a obra social, administrar '
          'seu patrimônio, disciplinar as atividades de seus membros, organizar e emancipar igrejas locais, aceita como fiel interpretação da Bíblia '
          'Sagrada a seguinte \'Declaração de Fé\':\n\n 1. Cremos na Bíblia como palavra de Deus, inspirada e autorizada, a única infalível.\n\n 2. Cremos '
          'em um Deus, eternamente existente em três pessoas: Pai, Filho e Espírito Santo.\n\n 3. Cremos na divindade de nosso Senhor Jesus Cristo, seu '
          'nascimento virginal, sua vida sem pecado, seus milagres, sua morte vicária e sacrificial pelo seu sangue derramado, em sua ressurreição, sua '
          'ascensão à destra de Deus Pai e seu retorno pessoal em poder e glória.\n\n 4. Cremos no ministério atual do Espírito Santo, e nos seus Dons.\n\n '
          '5. Cremos no Batismo com o Espírito Santo, subsequente de um coração limpo.\n\n 6. Cremos no falar em outras línguas, conforme o Espírito Santo '
          'concede que falemos.\n\n 7. Cremos na ressurreição dos salvos e dos perdidos; os primeiros para vida e os demais para condenação eterna.\n\n 8. '
          'Cremos na unidade espiritual dos crentes em nosso Senhor Jesus Cristo.\n\n 9. Cremos que a Bíblia é a única regra de fé e prática. Nenhum outro '
          'livro ou ensino pode ser comparado a ela. A Bíblia contem todo o conselho de Deus para a nossa vida. Por isso não podemos tirar nem acrescentar '
          'verdade alguma àquelas reveladas por ela.\n\n 10. Cremos que a Bíblia possui sessenta e seis livros, sendo trinta e nove no Antigo Testamento e '
          'vinte e sete no Novo Testamento. Os livros chamados apócrifos, não sendo inspirados, não tendo autoridade sobre a Igreja de Deus.\n\n 11. Cremos '
          'em um único Deus, alto suficiente, eterno, imutável, onipotente, onisciente e onipresente.\n\n 12. Cremos que Deus criou todas as coisas que '
          'existem a partir do nada, pelo poder de sua palavra. Sem Ele, nada do que foi feito se fez. Fora de Deus não há outros deuses, mas apenas criaturas.'
          '\n\n 13. Cremos que Jesus é o único salvador da humanidade. Ele é o único intermediário entre Deus e os homens.\n\n 14. Cremos que o acesso à salvação'
          ' é conseguido individualmente, por meio da fé em Cristo e através da obra realizada pelo Espírito Santo no coração humano. Trata-se de uma mudança '
          'de vida, que a Bíblia chama de novo nascimento.\n\n 15. Cremos no Batismo por imersão e em nome do Pai, do Filho e do Espírito Santo.\n\n 16. Cremos '
          'no Batismo, é o sinal da aliança do crente com Cristo. Quando o batizando é mergulhado, professa neste ato que morreu para a velha vida. Quando é '
          'levantado, esta significando que ressuscitou para uma nova vida.\n\n 17. Cremos que o Batismo só deve ser ministrado a pessoas convertidas, que '
          'publicamente professam sua fé em Cristo. Por isso não devemos batizar nem crianças nem infiéis.\n\n 18. Cremos que o batismo e a Ceia do Senhor são '
          'ordenanças sagradas, instituídas por Jesus. Delas devem participar somente as pessoas salvas e comprometidas com Ele.\n\n 19. Cremos que os elementos '
          'da Ceia são pão e vinho. O pão representa o corpo de Cristo e o vinho o seu sangue. No ritual da ceia celebramos Sua morte por nós, até que Ele venha.'
          '\n\n 20. Cremos que, uma vez a Igreja reunida, e os elementos consagrados para o fim da celebração da Ceia, a participação na Ceia do Senhor é a nossa '
          'comunhão com o corpo e o sangue de Jesus. Embora o pão continue sendo pão e o vinho permaneça vinho, a presença espiritual de Jesus em nós é real.\n\n '
          '21. Cremos que somente devem participar da Ceia pessoas convertidas que selaram seu compromisso com Deus através do Batismo e com a Igreja através do '
          'Estatuto e Regimento Interno. Devemos participar Dela com o espírito de gratidão, temos e com confissão de pecados a Deus.\n\n 22. Cremos que Jesus Cristo'
          ' voltará no dia final, para julgar os mortos e os vivos, e todos comparecerão diante Dele.\n\n 23. Cremos que às pessoas salvas por Jesus nesta vida não '
          'entrarão em juízo, pois os seus pecados não são mais levados em conta.\n\n 24. Cremos que, no dia final, os salvos de todos os tempos serão transformados,'
          ' deixando sua natureza corruptível e pecaminosa, sendo revestidos de incorruptibilidade e perfeição. Entraremos assim num estado glorioso de Comunhão'
          ' perfeita com Deus.\n\n 25. Cremos que as pessoas que não foram salvas por Jesus durante esta vida, serão condenadas no juízo final. Não há oportunidade '
          'de salvação depois desta vida aqui.\n\n 26. Cremos que Deus destruirá esta criação e fará novos céus e nova terra, onde reinam a paz e justiça, onde '
          'habitaremos para sempre.\n\n 27. Cremos no casamento como instituição divina, conforme o propósito da criação; macho e fêmea, unido homem e mulher pelo '
          'casamento civil e religioso.\n\n 28. Esperamos o arrebatamento da Igreja e a ressurreição dos mortos e a vida do século vindouro. Amém.\n \n § 2º - A '
          '\'ICEA\', que não participa de movimentos e sociedades ou associações que fujam aos princípios bíblicos, poderá relacionar-se para fins de cooperação com '
          'igrejas e ministérios evangélicos, sem, praticar ou concordar com o proselitismo.\n \n § 3º - O Campo de atividade da \'ICEA\' pode ser estendido, com '
          'implantação de missões ou pontos de pregação, vinculados orgânica, espiritual e doutrinariamente ao ministério,a todo o território nacional.\n \n § 4º - '
          'A \'ICEA\', que é soberana em suas decisões e não está subordinada a qualquer outro ministério, igreja ou entidade, poderá confeccionar um Regimento Interno'
          ' que, devidamente aprovado em Assembléia Extraordinária, disciplinará particularidades de seu funcionamento, a criação dos órgãos internos que se fizerem '
          'necessários e questões outras não abrangidas por este Estatuto, desde que guardem a necessária correlação aos princípios e finalidades da instituição.\n \n '
          '§ 5º - A \'ICEA\' não distribui entre os seus membros, empregados ou doadores eventuais, participações ou parcelas do seu patrimônio, auferidas mediante o '
          'exercício de suas atividades, e as aplica na consecução do seu objetivo eclesiástico e ministérios.\n\n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo II',
      subtitulo: 'ADMISSÃO, DEMISSÃO E EXCLUSÃO DE MEMBROS',
      conteudo:
      'Art. 2º - Poderão ser membros da \'ICEA\' pessoas de ambos os sexos, independentemente de nacionalidade, raça ou condição social, '
          'desde que aceitem os credos e objetivos do ministério, preencham os requisitos exigidos neste Estatuto e sejam recebidos em reuniões de '
          'cultos solenes.\n \n Art. 3º - O número de membros e ilimitado e estes se dividem nas seguintes categorias:\n a) \"Membros Especiais\";\n '
          'b) \"Membros Regulares\";\n c) \"Membros Elegíveis\";\n \n Parágrafo Único - A qualidade de membro é intransmissível.\n \n Art. 4º - Para '
          'ser admitido como membro especial ou membro regular o pretendente deverá, dentre outros requisitos a serem preenchidos, aceitar incondicionalmente,'
          ' mediante lavratura de TERMO DE CONCORDÂNCIA, o inteiro teor deste Estatuto e suas respectivas declarações de fé.\n \n Parágrafo Único - Os membros'
          ' elegíveis obrigatoriamente emergirão da categoria de membros regulares, mediante cumprimento de exigências e requisitos listados neste Estatuto.'
          '\n \n Art. 5º - São requisitos para admissão de Membros especiais e Membros regulares:\n a) Se possível o cumprimentos de ciclo de discipulado pessoal'
          ' a ser elaborado e especificado pelo Conselho Administrativo.\n b) Parecer favorável da Igreja reunida em culto solene.\n c) Batismo, Jurisdição ou '
          'Transferência.\n d) E pública profissão de fé, com aceitação declarada das doutrinas, credos e confissões da \'ICEA\'.\n \n Parágrafo Único - Em caso'
          ' de pretendentes oriundos de outras Igrejas evangélicas que professem a mesma fé, ordem, disciplina e doutrina da ICEA as exigências das alíneas '
          '\"a,b,c,d\" poderão ser suprimidas pelo Conselho Administrativo, desde que receba a apostila para leitura em casa.\n \n Art. 6º - O Cerimonial de batismo'
          ' e/ou profissão de fé realizados na \'ICEA\' por si só não implicam consequente admissão do batizado ou professo no rol de membros, inclusão esta que '
          'dependerá do cumprimento cumulativo dos demais requisitos listados no Art. 5º do presente Estatuto.\n \n Art. 7º - Os membros que não cumprirem as '
          'determinações do presente Estatuto ou mantiverem conduta incompatível com o mesmo estarão sujeitos às seguintes penalidades:\n a) admoestação;\n b) '
          'disciplina;\n c) desvinculação ou demissão.\n \n § 1º - A pena de disciplina, que consiste na total suspensão dos direitos do membro e afastamento '
          'definitivo de cargos ou funções de liderança que ocupe na Igreja, será sempre por prazo determinado a ser fixado pelo Conselho Administrativo, não '
          'podendo ser inferior a 30 (trinta) dias; já tendo sido o membro punido, pelo mesmo motivo, com disciplina anteriormente, o prazo da nova disciplina não'
          ' poderá ser inferior a 60 (sessenta) dias, e no máximo 90 (noventa) dias.\n \n § 2º - A pena de admoestação será registrada em ata e será comunicada '
          'pessoalmente ao disciplinado por um membro do CONSELHO ADMINISTRATIVO; o membro será punido com admoestação apenas uma única vez, no que a reincidência '
          'determinará a imediata aplicação da pena de disciplina ou desvinculação.\n \n Art. 8º - Entende-se por JUSTA CAUSA a ensejar a demissão ou descinculação '
          'do membro:\n a) Descumprimento do Estatuto ou Regimento Interno.\n b) Conduta que atente aos preceitos da Bíblia Sagrada ou da \"Declaração de Fé\".\n c) '
          'Comportamento ou vivência que enfoque, insinue a relação ou o desejo sexual fora dos limites do casamento.\n d) Comportamento ou vivência homoafetiva, bem'
          ' como apologia à mesma.\n e) Não cumprimento dos deveres enumerados no Art. 18º.\n f) Prática de crime ou contravenção, após transito em julgado.\n g) '
          'Insubmissão às autoridades administrativas ou espirituais da \'ICEA\'.\n h) Aplicação, por três vezes, da penalidade de disciplina.\n \n § 1º - O CONSELHO'
          ' ADMINISTRATIVO, poderá pelas circunstâncias do fato e histórico de boa conduta do membro, converter a pena de desvinculação em disciplina, sempre cumulada'
          ' esta substituição com a perda de eventual cargo ou função exercida pelo membro punido na instituição.\n \n Art. 9º - Cabe o CONSELHO ADMINISTRATIVO, de ofício'
          ' ou mediante requerimento por escrito de qualquer interessado que apresente provas legítimas instaurar, instruir e solucionar todo e qualquer procedimento '
          'disciplinar, apresentando-o, ao final, integralmente para conhecimento da Assembléia Geral.\n \n Parágrafo Único - A instauração de procedimento disciplinar '
          'para apuração de faltas cometidas por membros do CONSELHO ADMINISTRATIVO é competência privativa da Assembléia Geral, que no mesmo ato de instauração nomeará '
          'comissão para instruir o processo e apresentar parecer, em data estabelecida, para deliberação e julgamento em Assembléia Geral sempre com o voto concorde da '
          'maioria absoluta dos presentes, não podendo deliberar sem a presença mínima de 1/3 (a terça parte) dos membros.\n \n Art. 10º - O procedimento disciplinar para'
          ' apuração de todas e quaisquer faltas garantirá o contraditório e ampla defesa ao membro investigado.\n \n Art. 11º - As penas de disciplina e admoestação poderão'
          ' ser aplicadas a fatos não constantes no rol de justa causa para desvinculação ou demissão.\n \n Art. 12º - Sendo instaurado processo disciplinar para apuração '
          'de fatos passíveis de quaisquer das penalidades listadas neste Estatuto, o membro investigado será imediatamente afastado e impedido de exercer qualquer direito '
          'ou função que lhe tenha sido conferido na instituição; a aplicação de penalidades de admoestação ou disciplina tornará definitivo o afastamento de cargos ou funções'
          ' e ensejará a perda de todos e quaisquer direitos até que seja cumprida integralmente.\n \n Art. 13º - A demissão do membro poderá se dar por abandono, caracterizado'
          ' pelo decurso de três meses sem que compareça a qualquer trabalho da \'ICEA\', ou mediante afirmação por escrito de três membros.\n \n Parágrafo Único - A demissão '
          'do membro também poderá se dar mediante simples requerimento; sendo que o respectivo termo, com a assinatura do solicitante será arquivado pela instituição.\n \n Art.'
          ' 14º - Desvinculado o membro ou tendo este deixado a \'ICEA\' voluntariamente, não será possível pleitear o recebimento em restituição das contribuições que tenha '
          'prestado ao patrimônio da instituição.\n \n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo III',
      subtitulo: 'DOS DIREITOS E DEVERES DOS MEMBROS',
      conteudo:
      'Art. 15º - A \'ICEA\' terá as seguintes categorias de membros:\n a) \"Membros Especiais\"\n b) \"Membros Regulares\"\n c) \"Membros Elegíveis\"\n \n § 1º - São '
          'considerados membros especiais àqueles que pela lei civil sejam ou relativamente incapazes de exercer pessoalmente os atos da vida civil; os membros especiais não possuem '
          'direito a voto na Assembléia Geral, apenas à voz; porém, cessada esta incapacidade, estes automaticamente se tornarão membros regulares, com direito a voz e voto.\n \n § 2º '
          '- São considerados membros elegíveis todos os Obreiros e Obreiras aqueles que, por preencherem requisitos determinados neste Estatuto e gozarem de aprovação após apresentação do '
          'parecer favorável do CONSELHO ADMINISTRATIVO.\n \n § 3º - São considerados membros regulares todos aqueles admitidos pela \'ICEA\' que sejam civilmente capazes, e terem cumprido '
          'os requisitos listados neste Estatuto.\n \n § 4º - Os \"MINISTROS DE CONFISSÃO RELIGIOSA\" oriundos de outras comunidades evangélicas que professem a mesma fé e aceitem as doutrinas '
          'da \'ICEA\' poderão se tornar imediatamente membros mediante decisão fundamentada do Conselho Administrativo, portanto a carta de apresentação ou por jurisdição 06 (seis) meses após '
          'ficando em observação.\n \n Art. 16º - Constituem direitos de todos os membros:\n a) receber assistência religiosa e espiritual da \'ICEA\'.\n b) participar ativamente dos cultos e '
          'outras atividades da \'ICEA\', que como assistentes, quer como responsável por alguma(s) incumbência(s), exceto aquela(s) própria(s) do ministério da Palavra e aquelas respectivas '
          'aos detentores de cargos eletivos.\n \n § 1º - Não há, entre os membros, direitos e obrigações recíprocos.\n \n § 2º - Os membros não respondem, nem mesmo subsidiariamente, pelas '
          'obrigações sociais.\n \n Art. 17º - Para que um membro regular venha a se tornar elegível (Obreiros e Obreiras) ou em cargos de administração da \'ICEA\', é preciso que:\n a) '
          'Cumpra mais de 02 (dois) anos como membro regular.\n b) Conclua roteiro de estatuto sistemático da bíblia elaborado pelo Conselho Administrativo.\n c) Obtenha parecer favorável do '
          'Conselho Administrativo.\n d) Seja de bom testemunho, cheio do Espírito Santo e de sabedoria.\n e) Contribua sistematicamente com seus Dizimos e Ofertas, para a \'ICEA\'.\n \n Art. '
          '18º - São deveres dos membros:\n a) Cooperar para o desenvolvimento e prestígio da \'ICEA\'.\n b) Observar o Estatuto e Regimento Interno da \'ICEA\'.\n c) Comparecer às reuniões da '
          'Assembléia Geral, quando convocado.\n d) Frequentar assiduamente os trabalhos e cultos públicos promovidos pela \'ICEA\'.\n e) Apoiar voluntariamente com seus legados, dádivas e '
          'contribuições espontâneas a obra ostentada pela \'ICEA\', que visa a expansão do Reino de Deus.\n f) Observar irreprovável conduta e uma vida exemplar.\n g) Contribuir da sua parte '
          'em tudo quanto requeira a \'ICEA\', com sua pessoa, seus conhecimentos, seus dons e seus talentos, bem como com o seu trabalho.\n \n Art. 19º - A simples possibilidade e a efetiva '
          'titularidade de quotas ou fração idéia do patrimônio da associação \'ICEA\' é absolutamente afastada e rejeitada por este Estatuto, que expressamente apregoa o impedimento de qualquer '
          'membro ou terceiro estranho à associação vir a ser ou intentar ser proprietário de títulos representativos do patrimônio da entidade.\n \n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo IV',
      subtitulo: 'DAS FONTES DE RECURSOS PARA MANUTENÇÃO',
      conteudo:
      'Art. 20º - O patrimônio e a receita da \'ICEA\' constituir-se-ão dos bens e direitos que lhe couberem, pelos que vier a adquirir no exercício de suas atividades, pela '
          'contribuição de seus membros, congregados e simpatizantes, pelas subvenções e doações oficiais e particulares.\n \n § 1º - A receita da Igreja será constituída das contribuições '
          'levantamento de Campanhas Financeiras, Dízimos, Ofertas voluntárias, de seus membros e não membros e Doações de entidades privadas, ou pessoas físicas desde que tais recursos '
          'não tenham sua origem em atividades ilegais.\n \n § 2º - É vedado o empréstimo de aparelhos elétricos, eletrônicos ou de percussão, instrumentos ou veículos de propriedade da '
          'Igreja, exceto quando autorizado pelo Conselho Administrativo.\n \n Art. 21º - A \'ICEA\' poderá receber contribuições, doações, legados e subvenções, de pessoas físicas ou '
          'jurídicas nacionais e internacionais, destinados à formação e ampliação de seu patrimônio ou à realização de trabalhos específicos.\n \n Art. 22º - Toda a receita será aplicada '
          'única e exclusivamente na consecução das finalidades e objetivos da \'ICEA\'.\n \n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo V',
      subtitulo: 'DOS ÓRGÃOS DELIBERATIVOS E ADMINISTRATIVOS',
      conteudo:
      'Art. 23º - A \'ICEA\' possui os seguintes órgãos de administração e fiscalização:\n \n I - Assembléia Geral\n II - Conselho Administrativo\n III - Conselho Fiscal\n IV - '
          'Conselho Espiritual\n \n Parágrafo Único - O presente Estatuto é reformável no tocante à administração, mediante voto concorde de 2/3 (dois terços) dos presentes a Assembléia '
          'Geral especialmente convocada para esse fim, não podendo esta deliberar sem a presença mínima de 1/2 (metade) dos associados em primeira convocação e 1/3 (um terço) dos associados'
          ' em segunda e última convocação.\n\n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo VI',
      subtitulo: 'ASSEMBLÉIA GERAL',
      conteudo:
      'Art. 24º - A Assembléia Geral, que sempre será presidida pela diretoria do CONSELHO ADMINISTRATIVO, é órgão máximo de deliberação e fiscalização da \'ICEA\', com poder '
          'soberano, e se constituirá, na proporção dos respectivos direitos, dos membros especiais, regulares e elegíveis em pleno gozo de seus direitos estatutários.\n \n Art. 25º - Compete'
          ' à Assembléia Geral todas as deliberações relacionadas às atividades e administração da \'ICEA\' quando esta entender por bem avocar tal competência do CONSELHO ADMINISTRATIVO, bem'
          ' como a escolha do Pastor Presidente, e demais integrantes do CONSELHO ADMINISTRATIVO, a destituição dos mesmos, a alteração do Estatuto e a aprovação das contas, sendo que o quorum '
          'para sua instauração em reunião ordinária ou extraordinária, com exceção às exigências diferenciadas e expressas neste Estatuto, observará à maioria simples dos membros votantes em '
          'primeira convocação ou de 1/4 (um quarto) dos associados votantes em segunda convocação, trinta minutos após a primeira, sendo que as deliberações se darão pela maioria simples dos '
          'presentes votantes.\n \n Art. 26º - Para a destituição de membros do CONSELHO ADMINISTRATIVO, do CONSELHO FISCAL, para alienação de bens imóveis com valor superior a 50 (cinquenta) '
          'salários mínimos e alteração do Estatuto é exigido o voto concorde de 1/2 (metade) + (mais) 1 (um) dos votantes presentes à assembléia geral especialmente convocada para esse fim, '
          'não podendo ela deliberar, em primeira convocação, sem a maioria absoluta dos membros votantes, ou com menos de 1/3 (um terço) destes em segunda convocação 30 (trinta) minutos após.\n \n'
          ' Art. 27º - A Assembléia Geral se realizará, extraordinariamente, sempre que se fizer necessário, e será convocada:\n \n I - Pelo CONSELHO ADMINISTRATIVO ou mediante convocação do '
          'respectivo Presidente.\n II - Pelo CONSELHO FISCAL.\n III - Por requerimento de 1/5 (um quinto) dos membros em pleno gozo de seus direitos estatutários.\n IV - Por deliberação da '
          'Assembléia Geral Ordinária, mediante aprovação de proposta que inclua desde logo a pauta dos assuntos a serem tratados.\n \n Art. 28º - A Assembléia Geral será convocada por edital '
          'afixado na sede da \'ICEA\', por Boletim Interno ou outros meios convenientes, com antecedência mínima de 15 (quinze) dias quando ordinária ou 08 (oito) dias quando extraordinária, '
          'exceto no caso de reforma do presente Estatuto, cujo prazo de convocação será de 30 (trinta) dias.\n \n Parágrafo Único - Em qualquer convocação, a Assembléia Geral não poderá ser '
          'instaurada sem a presença mínima de 2/3 (dois terços) dos integrantes do CONSELHO ADMINISTRATIVO.\n \n Art. 29º - A Assembléia Geral, que se reunirá ordinariamente uma vez por ano para'
          ' aprovação das contas e, sendo pertinente, para eleição aos cargos que se fizerem necessários, mediante convocação do CONSELHO ADMINISTRATIVO que já neste ato apresentará a pauta com os'
          ' assuntos a serem tratados, deliberará costumeiramente por aclamação; exigindo, porém, qualquer interessado ou a própria controvérsia da matéria a ser decidida, a votação será por '
          'escrutínio secreto.\n \n Parágrafo Único - Nas reuniões da Assembléia Geral não serão admitidas procurações.\n \n Art. 30º - Ocorrendo qualquer circunstância que venha a afastar '
          'provisória ou definitivamente o presidente do CONSELHO ADMINISTRATIVO, este será imediatamente substituído pelo vice-presidente, e, na falta deste, o Conselho Administrativa nomeará'
          ' novo presidente, ratificado pela Assembléia Geral, até o término do mandato.\n \n\n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo VII',
      subtitulo: 'CONSELHO ADMINISTRATIVO',
      conteudo:
      'Art. 31º - O CONSELHO ADMINISTRATIVO, que constitui a própria diretoria da \'ICEA\', é responsável pela execução da administração, gerenciamento dos negócios e do patrimônio da'
          ' \'ICEA\', será constituído por membros, elegíveis e membros regulares sendo sua composição de um Presidente, um Vice-Presidente, Primeiro e Segundo Secretários, Primeiro e Segundo '
          'Tesoureiros e um Diretor de Patrimônio, totalizando este conselho um número de 07 (sete) integrantes.\n \n § 1º - O mandato dos integrantes deste conselho, que obrigatoriamente deverão'
          ' estar em plena comunhão com a Igreja, com exceção do Presidente, deverá ser de 02 (dois) anos, iniciando o mandato na 1ª quinzena de janeiro e estendendo-se anualmente, deverá ser '
          'eleita em Assembléia Geral convocada por meio de edital de convocação com o prazo não inferior a 15 (quinze) dias afixados no quadro de avisos, sendo permitida a reeleição.\n \n § 2º '
          '- Caberá ao Presidente do CONSELHO ADMINISTRATIVO ou ao Presidente em exercício, além de seu voto ordinário, o voto de desempate nas reuniões do CONSELHO ADMINISTRATIVO e da Assembléia'
          ' Geral.\n \n § 3º - O Pastor da Igreja será necessária e obrigatoriamente o Presidente, e será eleito por prazo de 02 (dois) anos, em Assembléia Geral, convocada por meio de edital de '
          'convocação com o prazo não inferior a 15 (quinze) dias, podendo a igreja interromper o ministério pastoral a qualquer tempo Assembléia Geral convocada especialmente para este fim por '
          'meio de edital de convocação observando os moldes de convocação especificado neste parágrafo. E será sempre o Presidente do Conselho Administrativo e do Conselho Espiritual.\n \n § 4º '
          '- Aos pastores locais e obreiros credenciados, inclusive das congregações e instituições filiadas, é garantido direito de assento e voz no CONSELHO ADMINISTRATIVO.\n \n Art. 32º - '
          'Compete ao CONSELHO ADMINISTRATIVO:\n a) Cumprir e fazer cumprir o presente Estatuto, as decisões da Igreja em Assembléia Geral, suas próprias deliberações firmadas em reunião e '
          'supervisionar o CONSELHO FISCAL.\n b) Organizar os livros necessários a toda escrituração da Igreja.\n c) Zelar pelo patrimônio e por todos os bens da \'ICEA\'.\n d) Entrevistar '
          'pretendentes à integração do rol de membros que decidirá ou não pela inclusão do pretendente.\n e) Presidir, instituir e solucionar procedimentos administrativos disciplinares, enviando'
          ' seu veredicto para conhecimento dos membros.\n f) Entrevistar e emitir parecer de membro regular que tenha o chamado e a vocação para o ministério.\n g) Elaborar o Regimento Interno '
          'e Código de Ética.\n h) Organizar, emancipar, fundar e dissolver congregações e instituições filiadas.\n i) Aprovar os planos de trabalho para o campo.\n j) Vender, doar, alugar ou '
          'emprestar bens patrimoniais da \'ICEA\', bem como adquirir, alugar, receber bens em nome da \'ICEA\', com o valor igual ou inferior a 50 (cinquenta) salários mínimos. Bens com valores'
          ' acima, só mediante autorização da Assembléia Geral através de votação com o resultado igual a 50% (cinquenta por cento) mais um dos votantes presentes na Assembléia Geral.\n \n Art. '
          '33º - O CONSELHO ADMINISTRATIVO se reunirá de dois em dois meses ou sempre que o exijam os interesses da Igreja.\n \n Art. 34º - Compete ao Presidente:\n I - Representar a \'ICEA\' ativa'
          ' e passivamente, judicial e extrajudicialmente.\n II - Convocar e presidir as reuniões dos CONSELHOS e da Assembléia Geral, nas quais sempre terá voto de minerva.\n III - Admitir e '
          'demitir funcionários.\n IV - Assinar com o 1º Tesoureiro escrituras de compra e venda, hipotecas, cessões e contratos, sempre mediante autorização do Conselho Administrativo ou da '
          'Assembléia Geral, conforme Art. 32 em sua letra \"J\".\n V - Assinar credenciais de obreiros e membros.\n VI - Incentivar o entrosamento entre a sede e congregações.\n \n Art. 35º - '
          'Compete ao Vice-Presidente:\n I - Substituir o presidente em sua falta ou impedimento.\n II - Assumir o mandato em caso de vacância até o seu término.\n III - Prestar, de modo geral, '
          'sua colaboração ao Presidente.\n \n Art. 36º - Compete ao Primeiro Secretário:\n I - Secretariar as reuniões do CONSELHO ADMINISTRATIVO e da Assembléia Geral e redigir as atas.\n II - '
          'Publicar todas as notícias de atividade da entidade.\n III - Elaborar, sob orientação do Presidente, a pauta das reuniões do CONSELHO ADMINISTRATIVO e da Assembléia Geral.\n IV - '
          'Coordenar e encaminhar as correspondências internas e externas.\n V - Escriturar e manter em dia o corpo de membros da \'ICEA\'.\n \n Art. 37º - Compete ao Segundo Secretário:\n I - '
          'Substituir o Primeiro Secretário em suas faltas ou impedimentos.\n II - Assumir o mandato, em caso de vacância, até o seu término.\n III - Prestar, de modo geral, a sua colaboração ao'
          ' Primeiro Secretário.\n \n Art. 38º - Compete ao Primeiro Tesoureiro:\n I - Arrecadar e contabilizar as contribuições dos membros, rendas, auxílios e donativos, mantendo em dias os '
          'livros da \'ICEA\'.\n II - Pagar as contas autorizadas pelo Presidente.\n III - Apresentar relatórios de receitas e despesas, sempre que forem solicitadas.\n IV - Apresentar ao Conselho'
          ' Fiscal a escrituração da \'ICEA\' incluindo os relatórios de desempenho financeiro e contábil e sobre as operações patrimoniais realizadas.\n V - Conservar, sob a sua guarda e '
          'responsabilidade os documentos relativos a tesouraria.\n VI - Manter o numerário em estabelecimento de crédito, sendo que a abertura de conta corrente e toda a movimentação de qualquer'
          ' valor mantido em referida instituição financeira somente se dará com assinatura conjunta do tesoureiro e do presidente.\n \n Art. 39º - Compete ao Segundo Tesoureiro:\n I - Substituir '
          'o Primeiro Tesoureiro em suas faltas ou impedimentos.\n II - Assumir o mandato, em caso de vacância, até o seu término.\n III - Prestar, de modo geral, sua colaboração ao Primeiro '
          'Tesoureiro.\n \n Art. 40º - Compete ao Diretor de Patrimônio, prover a manutenção das necessidades físicas e patrimoniais da \'ICEA\', mantendo um cadastro de controle e relação de bens.'
          '\n \n Art. 41º - Nenhum membro do CONSELHO ADMINISTRATIVO da \'ICEA\', sob qualquer forma, será remunerado em razão do exercício de sua função administrativa; sendo que o respectivo '
          'PASTOR PRESIDENTE e os demais MINISTROS DE CONFISSÃO RELIGIOSA da \'ICEA\', poderão ser remunerados por seus serviços de vocação eclesiástica e ministerial.\n \n § 1º - O Pastor Presidente'
          ' e os Pastores dirigentes de Congregações receberão proventos a título de remuneração pastoral, renda eclesiástica ou prebenda, em virtude exclusivamente do exercício de suas funções '
          'pastorais e ministeriais.\n \n § 2º - A remuneração ou a renda eclesiástica, dos Pastores, Presidente e dirigentes de Congregações, serão fixadas em 20% (vinte por cento) das respectivas'
          ' entradas de cada Igreja; Sede e Congregações, levando em conta o volume de trabalhos e as responsabilidades exercidas pelo Obreiro dirigente, inclusive o pagamento do 13º (décimo terceiro)'
          ' salário, na mesma proporção. Sendo que as férias o Obreiro dirigente deverá gozar o período adquirido, não sendo de interesse da Igreja ou Congregação comprar suas férias.\n \n § 3º - '
          'O Pastor poderá a qualquer tempo apresentar a Igreja sua carta de exoneração do ministério pastoral, com trinta dias de antecedência.\n \n\n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo VIII',
      subtitulo: 'CONSELHO FISCAL',
      conteudo:
      'Art. 42º - O Conselho Fiscal será constituído por 03 (três) membros e seus respectivos suplentes, escolhidos pela Assembléia Geral.\n \n § 1º - O mandato do Conselho Fiscal '
          'será coincidente com o mandato do CONSELHO ADMINISTRATIVO.\n \n § 2º - Em caso de vacância, o mandato será assumido pelo respectivo suplente, até o seu término.\n \n Art. 43º - Compete'
          ' ao Conselho Fiscal:\n I - Examinar os livros de escrituração da \'ICEA\'.\n II - Opinar sobre os balanços e relatórios de desempenho financeiro e contábil e sobre as operações'
          ' patrimoniais realizadas.\n III - Requisitar ao Primeiro Tesoureiro, a qualquer tempo, documentação comprobatória das operações econômico-financeiras realizadas pela \'ICEA\'.\n IV'
          ' - Apresentar o balanço das contas para aprovação pelo Conselho Administrativo.\n \n Art. 44º - O Conselho Fiscal se reunirá ordinariamente a cada 06 (seis) meses e extraordinariamente'
          ' sempre que se fizer necessário.\n \n\n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo IX',
      subtitulo: 'CONSELHO ESPIRITUAL',
      conteudo:
      'Art. 45º - O CONSELHO ESPIRITUAL representa, a \'ICEA\' espiritual, doutrinária, evangelística, filantrópica, educativa, artisticamente em missões e ministérios com seus segmentos.'
          '\n \n § 1º - A Presidência do CONSELHO ESPIRITUAL é exercida pelo Pastor Presidente, será auxiliado pelos: Pastores, Presbíteros, Evangelistas, Diáconos e Missionárias.\n \n § 2º - O '
          'Conselho Espiritual é formado por Pastores, Presbíteros, Evangelistas, Diáconos e Missionárias e serão escolhidos, dentre os membros elegíveis, pelo Conselho Administrativo, ou pelo seu'
          ' pastor.\n \n § 3º - O Pastor Presidente deverá defender e cumprir o Estatuto da \'ICEA\', observar as normas, sustentar a união, a integridade e a vida espiritual da \'ICEA\'.\n \n Art.'
          ' 46º - Em caso de vacância do Pastor Presidente far-se-á substituição do cargo por eleição de candidato(s) indicado(s) pelo CONSELHO ADMINISTRATIVO em Assembléia Geral.\n \n Art. 47º - '
          'Compete exclusivamente ao Pastor Presidente:\n I - Exercer a presidência do Conselho Espiritual, auxiliado daqueles descritos no Art. 45º, § 1º, do presente Estatuto.\n II - Convocar e '
          'presidir as Reuniões do Conselho.\n III - Consagrar novos \"Ministros de Confissão Religiosa\", após devidamente apreciados pelo CONSELHO ADMINISTRATIVO e ratificados em Assembléia Geral.'
          '\n IV - Dirigir os atos Litúrgicos Eclesiásticos.\n V - Elaborar, criar e prover todos os materiais didáticos para o bem-estar dos membros da \'ICEA\'.\n VI - Orientar, distribuir oficio,'
          ' enviar, liderar reunião do Conselho Espiritual, treinar líderes para exercer os ministérios e departamentos, bem como coordená-los.\n VII - Representar a \'ICEA\' em todos os contextos, '
          'ativa, passiva, judicial e extrajudicialmente em eventos espirituais e sociais.\n VIII - Manter a ordem quanto a assuntos teológicos, doutrinários e morais, quanto a pureza da Doutrina '
          'Bíblica e da vida cristã.\n IX - Admoestar, disciplinar, exortar, consolar, cuidar, ensinar, aconselhar, discipular, treinar, consolidar e enviar quaisquer membros ou pretendentes em suas'
          ' categorias, observado os termos do Capítulo II do presente Estatuto.\n X - Presidir doutrinaria e espiritualmente a \'ICEA\' em todo o território nacional.\n \n Parágrafo Único - O Pastor'
          ' Presidente poderá delegar as atribuições mencionadas no inciso IV, V, VII, VIII e IX aos auxiliares mencionados no Art. 45º, § 1º, do presente Estatuto.\n \n Art. 48º - Compete aos '
          'auxiliares do CONSELHO ESPIRITUAL:\n I - Realizar suas funções na área de sua competência; designadas pelo Pastor Presidente.\n II - Expedir instruções para a execução das suas funções aos'
          ' seus liderados.\n III - Apresentar ao Pastor Presidente relatório anual de sua gestão no Ministério. (no período de janeiro a dezembro).\n IV - Praticar atos pertinentes às atribuições '
          'que lhe forem outorgadas ou delegadas pelo Pastor Presidente.\n \n Art. 49º - O Regimento Interno disporá sobre a criação, estruturação e atribuições dos ministérios.\n \n Art. 50º - É '
          'vedado aos MINISTROS DE CONFISSÃO RELIGIOSA:\n I - Realizar casamento religioso, ou com efeito civil de pessoas que tenham comportamento ou vivência homoafetiva, bem como análoga à mesma.'
          '\n II - Realizar casamento religioso de membros ou pretendentes da \'ICEA\' com pessoas que não professam a mesma fé e preceitos.\n III - Batizar homoafetivos que assim vivam ou assim se '
          'comportam e casos análogos; bem como pessoas que não dêem bom testemunho e sejam réprobas em suas condutas diante da sociedade comum e da Assembléia Geral.\n IV - Ceder Púlpito a ministros'
          ' de confissão religiosa não evangélica, os classificados heréticos, desconhecidos do cristianismo Bíblico, apostatas e suspeitos diversos.\n V - Superintender ministérios alheios, e '
          'desmembrar o ponto de pregação, celular, congregações, missões e/ou igrejas pertencentes à \'ICEA\' para anexarem-se a outras denominações eclesiásticas.\n VI - Envolver-se em questões '
          'religiosas ecumênicas, bem como realizar atos ecumênicos em suas dependências a nível Regional e Nacional.\n \n Art. 51º - Compete ao Pastor Presidente aplicar aos seus auxiliares e '
          'liderados pena disciplinar cabível pelos motivos da presente seção:\n I - Abandono de Jurisdição e Ofício.\n II - Adesão a outros movimentos e/ou doutrinas heréticas.\n III - Renuncia de '
          'Jurisdição.\n IV - Por ter vida repreensível.\n V - Conluio e desmembramento mencionado no Art. 51º Inciso VI do presente Estatuto.\n \n Parágrafo Único - O Regimento Interno disporá sobre'
          ' as disciplinas a serem aplicadas a cada caso, e acrescentará os motivos indisciplinares conforme Estatuto da \'ICEA\'.\n \n Art. 52º - Caso o Pastor Presidente pratique atos que ensejam '
          'penas disciplinares, cabe ao CONSELHO ADMINISTRATIVO abrir inquérito, e convocar outro ministro da mesma confissão religiosa para julgar e decidir a pena a ser aplicada aos motivos descritos'
          ' no Art. 52º do presente Estatuto.\n \n\n',
    ),
    CapituloEstatuto(
      titulo: 'Capítulo X',
      subtitulo: 'CONDIÇÕES PARA ALTERAÇÃO ESTATUTÁRIA E DISSOLUÇÃO',
      conteudo:
      'Art. 53º - As alterações do Estatuto se farão a qualquer tempo, em Assembléia Geral convocada especialmente para esse fim, e dependerão da deliberação favorável a 2/3 (dois terços)'
          ' dos membros presentes, garantindo-se quorum mínimo para instauração da Assembléia Geral em primeira convocação de 1/2 (metade) dos associados votantes e em segunda convocação o mínimo '
          'de 1/3 (um terço) dos membros votantes.\n \n Art. 54º - Este Estatuto não poderá ser alterado estando a \'ICEA\' em processo de dissolução ou na iminência do mesmo.\n \n Parágrafo Único'
          ' - Em caso de dúvida suscitada por integrantes da administração ou 1/5 (um quinto) dos membros quanto à iminência de dissolução da \'ICEA\', esta será sanada pela impossibilidade de '
          'alteração do Estatuto.\n \n Art. 55º - Dissolvida a \'ICEA\', seu patrimônio será revertido para entidade de finalidade não econômica que possua fins os mais próximos possíveis desta '
          'instituição, mediante deliberação da Assembléia Geral.\n \n Art. 56º - Em caso de divisão da \'ICEA\', seu patrimônio permanecerá com aqueles que permanecerem fiéis à doutrina e '
          'princípios contidos neste Estatuto.\n \n Art. 57º - A dissolução da \'ICEA\' dar-se-á mediante voto favorável de 2/3 (dois terços) dos membros presentes à Assembléia Geral Extraordinária'
          ' especialmente convocada para tal fim, nos temos deste Estatuto, não podendo esta deliberar em qualquer convocação com menos de 1/3 (um terço) dos membros.\n \n Art. 58º - Ocorrida a '
          'dissolução da \'ICEA\' não será possível o recebimento em restituição das contribuições prestadas ao patrimônio da instituição, nem a ministérios ligados à mesma.\n \n Art. 59º - O '
          'presente Estatuto entra em vigor imediatamente após a aprovação em Assembléia Geral realizada na sede da Igreja e seu registro em Cartório.\n \n\n',
    ),
  ];

  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulIntermediario,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Estatuto'),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: capitulos.length,
        itemBuilder: (context, index) {
          final capitulo = capitulos[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            decoration: BoxDecoration(
              color: azulIntermediario,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              leading: Icon(Icons.speaker_notes, color: dourado),
              title: Text(
                capitulo.tituloCompleto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CapituloDetalheScreen(
                          capitulo: capitulos[index],
                          index: index,
                          capitulos: capitulos,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CapituloDetalheScreen extends StatefulWidget {
  final CapituloEstatuto capitulo;
  final int index;
  final List<CapituloEstatuto> capitulos;
  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  CapituloDetalheScreen({
    required this.capitulo,
    required this.index,
    required this.capitulos,
  });

  @override
  _CapituloDetalheScreenState createState() => _CapituloDetalheScreenState();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          capitulo.tituloCompleto,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          capitulo.conteudo,
          style: TextStyle(fontSize: 16, color: Colors.black, height: 1.5),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}

class _CapituloDetalheScreenState extends State<CapituloDetalheScreen> {
  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);

  double fontSize = 16;

  void abrirCapitulo(int novoIndex) {
    if (novoIndex >= 0 && novoIndex < widget.capitulos.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CapituloDetalheScreen(
                capitulo: widget.capitulos[novoIndex],
                index: novoIndex,
                capitulos: widget.capitulos,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.capitulo.tituloCompleto,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: azulProfundo,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                widget.capitulo.conteudo,
                style: TextStyle(fontSize: fontSize, color: Colors.black),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.index > 0
                      ? () => abrirCapitulo(widget.index - 1)
                      : null,
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  label: Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dourado,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.index < widget.capitulos.length - 1
                      ? () => abrirCapitulo(widget.index + 1)
                      : null,
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                  label: Text('Próximo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dourado,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => fontSize += 2),
                  icon: Icon(Icons.zoom_in, color: azulProfundo),
                  tooltip: 'Aumentar fonte',
                ),
                IconButton(
                  onPressed: () =>
                      setState(
                            () =>
                        fontSize = fontSize > 10 ? fontSize - 2 : fontSize,
                      ),
                  icon: Icon(Icons.zoom_out, color: azulProfundo),
                  tooltip: 'Diminuir fonte',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Igreja {
  final String nome;
  final String imagem;
  final List<String> endereco;
  final List<String> pastores;
  final String chavePix;
  final double latitude;
  final double longitude;

  Igreja({
    required this.nome,
    required this.imagem,
    required this.endereco,
    required this.pastores,
    required this.chavePix,
    required this.latitude,
    required this.longitude,
  });

  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
}

class IgrejasScreen extends StatelessWidget {
  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFFFFD700);
  final List<Igreja> igrejas = [
    Igreja(
      nome: 'Sede Bairro JK',
      imagem: 'assets/images/icea_sede_fachada.PNG',
      endereco: [
        'Rua Pablo',
        'Quadra 66-B, Lote 17',
        'Bairro JK Nova Capital',
        'Anápolis - Goiás',
      ],
      pastores: [
        'Hélio José de Almeida',
        'Josivan Nunes dos Santos',
        'Antonio Carlos Rodrigues dos Santos',
        'Ronan da Rocha Gomes',
        'Isaac Pereira Reis',
        'Mauro José Zeferino',
      ],
      chavePix: 'igreja.sede.anapolis@gmail.com',
      latitude: -16.341680,
      longitude: -48.931880,
    ),
    Igreja(
      nome: 'Boa Vista',
      imagem: 'assets/images/icea_boavista_fachada.PNG',
      endereco: [
        'Rua 14',
        'Quadra 21, Lote 8',
        'Bairro Boa Vista',
        'Anápolis - Goiás',
      ],
      pastores: [
        'Joaquim Vaz da Silva',
        'Olaim Ferreira de Sena',
        'Remer Pereira de Oliveira',
      ],
      chavePix: '36986057000159',
      latitude: -16.308410,
      longitude: -48.933520,
    ),
    Igreja(
      nome: 'Calisto Abrão',
      imagem: 'assets/images/icea_calistoabrao_fachada.PNG',
      endereco: [
        'Rua João Constante',
        'Quadra 12, Lote 27',
        'Bairro Calisto Abrão',
        'Anápolis - Goiás',
      ],
      pastores: [
        'Raimundo Carlos Rosa de Jesus',
        'Antonio Gomes da Silva',
        'Manoel Monteiro',
      ],
      chavePix: '',
      latitude: -16.327750,
      longitude: -48.974970,
    ),
    Igreja(
      nome: 'Jardim das Américas',
      imagem: 'assets/images/icea_jardimamericas_fachada.jpg',
      endereco: [
        'Rua Coronel Waltervan',
        'Quadra 11, Lote 17',
        'Bairro Jardim das Américas 3ª Etapa',
        'Anápolis - Goiás',
      ],
      pastores: ['Samuel Vieira Martins', 'José Carlos Morais'],
      chavePix: 'iceajaoficial@gmail.com',
      latitude: -16.283920,
      longitude: -48.941330,
    ),
    Igreja(
      nome: 'Assunção de Goiás',
      imagem: 'assets/images/icea_assuncao_fachada.png',
      endereco: [
        'Rua Pirineus',
        'Quadra 29, Lote 15',
        'Centro',
        'Assunção de Goiás - Goiás',
      ],
      pastores: [
        'Denésio de Sousa Lima',
        'Wesley Pereira de Souza Aguiar',
        'José Souza da Luz',
      ],
      chavePix: 'iceaassuncaodegoias@gmail.com',
      latitude: -15.207140,
      longitude: -48.698690,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sede = igrejas.first;
    final demais = igrejas.sublist(1);

    return Scaffold(
      backgroundColor: azulClaro,
      appBar: AppBar(
        title: Text('Nossas Congregações'),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // Card em destaque para a Sede
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IgrejaDetalheScreen(igreja: sede),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      sede.imagem,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      sede.nome,
                      style: TextStyle(
                        color: dourado,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Grid com as demais igrejas
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 2,
              children: demais.map((igreja) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IgrejaDetalheScreen(igreja: igreja),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          igreja.imagem,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            igreja.nome,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: dourado,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class IgrejaDetalheScreen extends StatelessWidget {
  final Color azulClaro = Color(0xFFE6F0FA);
  final Color azulIntermediario = Color(0xFF1A4CA0);
  final Color azulProfundo = Color(0xFF002D72);
  final Color dourado = Color(0xFF2CA59A);
  final Igreja igreja;

  IgrejaDetalheScreen({required this.igreja});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulClaro,
      appBar: AppBar(
        title: Text(igreja.nome),
        backgroundColor: azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              igreja.imagem,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 50),
            Text(
              'Endereço:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: azulProfundo,
              ),
            ),
            SizedBox(height: 10),
            ...igreja.endereco.map(
                  (e) => Text('$e', style: TextStyle(color: azulIntermediario)),
            ),
            SizedBox(height: 50),
            Text(
              'Pastores:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: azulProfundo,
              ),
            ),
            SizedBox(height: 10),
            ...igreja.pastores.map(
                  (p) => Text('$p', style: TextStyle(color: azulIntermediario)),
            ),
            SizedBox(height: 50),
            ElevatedButton.icon(
              icon: Icon(Icons.map),
              label: Text('Ver no Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: dourado,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                launchUrl(Uri.parse(igreja.googleMapsUrl));
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.copy),
              label: Text('Copiar chave PIX'),
              style: ElevatedButton.styleFrom(
                backgroundColor: dourado,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: igreja.chavePix));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFFFFD700),
                    content: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo_icea.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Chave PIX copiada: \n${igreja.chavePix} ',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
