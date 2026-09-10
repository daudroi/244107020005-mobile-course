import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double kWideBreakpoint = 700;

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Overview',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b87)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff63c5cb),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
      home: AcademicOverviewPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Semantics(
            label: isDark
                ? 'Dark theme enabled. Turn off to follow system theme.'
                : 'Dark theme disabled. Turn on to use dark theme.',
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 8),
                CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kWideBreakpoint;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(theme: theme),
                    const SizedBox(height: 24),
                    Text('This semester at a glance',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _ResponsiveRow(
                      isWide: isWide,
                      children: const [
                        InfoCard('Assignments', '8', '2 due this week', Icons.assignment_outlined),
                        InfoCard('Attendance', '92%', 'Above your target', Icons.event_available_outlined),
                        InfoCard('Portfolio', 'Ready', 'Updated today', Icons.folder_open_outlined),
                        InfoCard('Current week', '02', 'of 16 weeks', Icons.calendar_today_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ResponsiveRow(
                      isWide: isWide,
                      children: const [_ProgressCard(), _UpcomingCard()],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Profile photo of Alex Morgan',
            child: CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary,
              child: Text('AM', style: TextStyle(color: theme.colorScheme.onPrimary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, Alex', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text('Computer Science · Semester 4'),
              ],
            ),
          ),
          const Icon(Icons.waving_hand_outlined),
        ],
      ),
    );
  }
}

class _ResponsiveRow extends StatelessWidget {
  const _ResponsiveRow({required this.isWide, required this.children});
  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [for (final child in children) ...[child, const SizedBox(height: 12)]],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < children.length - 1 ? 8 : 0, left: i > 0 ? 8 : 0),
              child: children[i],
            ),
          ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard(this.title, this.value, this.caption, this.icon, {super.key});
  final String title;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title: $value. $caption',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.labelLarge),
                    Text(value, style: theme.textTheme.headlineSmall),
                    Text(caption, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Semester progress: 68 percent complete',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Semester progress', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: LinearProgressIndicator(value: .68, minHeight: 10)),
                const SizedBox(width: 12),
                Text('68%', style: theme.textTheme.titleMedium),
              ]),
              const SizedBox(height: 10),
              const Text('You are on track for your learning goals.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Next deadline: Human Computer Interaction lab, Friday at 23:59',
      child: Card(
        margin: EdgeInsets.zero,
        child: const ListTile(
          leading: Icon(Icons.schedule_outlined),
          title: Text('Next deadline'),
          subtitle: Text('HCI lab · Friday, 23:59'),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}
