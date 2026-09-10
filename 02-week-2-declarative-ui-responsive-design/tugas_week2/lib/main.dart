import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double kWideBreakpoint = 800;

void main() => runApp(const StudentPortalApp());

class StudentPortalApp extends StatefulWidget {
  const StudentPortalApp({super.key});

  @override
  State<StudentPortalApp> createState() => _StudentPortalAppState();
}

class _StudentPortalAppState extends State<StudentPortalApp> {
  bool isDark = false;
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campusly Student Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b87)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff63c5cb),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
      home: isLoggedIn
          ? PortalShell(
              isDark: isDark,
              onDarkChanged: (value) => setState(() => isDark = value),
              onLogout: () => setState(() => isLoggedIn = false),
            )
          : LoginPage(
              isDark: isDark,
              onDarkChanged: (value) => setState(() => isDark = value),
              onLogin: () => setState(() => isLoggedIn = true),
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({required this.isDark, required this.onDarkChanged, required this.onLogin, super.key});
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;
  final VoidCallback onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'student@campus.test');
  final passwordController = TextEditingController(text: 'password123');
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (formKey.currentState!.validate()) widget.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school_rounded, size: 36, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text('Campusly', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Semantics(
                            label: widget.isDark ? 'Turn off dark theme' : 'Turn on dark theme',
                            child: CupertinoSwitch(value: widget.isDark, onChanged: widget.onDarkChanged),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text('Welcome back', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text('Sign in to continue to your academic workspace.'),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Campus email', prefixIcon: Icon(Icons.email_outlined)),
                        validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email address' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: obscurePassword ? 'Show password' : 'Hide password',
                            icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null,
                      ),
                      const SizedBox(height: 22),
                      Semantics(
                        button: true,
                        label: 'Sign in to student portal',
                        child: FilledButton.icon(
                          onPressed: submit,
                          icon: const Icon(Icons.login),
                          label: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Demo account is pre-filled for this assignment.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PortalShell extends StatefulWidget {
  const PortalShell({required this.isDark, required this.onDarkChanged, required this.onLogout, super.key});
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;
  final VoidCallback onLogout;

  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  int selectedIndex = 0;

  static const destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewPage(onOpenProfile: () => setState(() => selectedIndex = 1)),
      const ProfilePage(),
      SettingsPage(isDark: widget.isDark, onDarkChanged: widget.onDarkChanged, onLogout: widget.onLogout),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= kWideBreakpoint;
        return Scaffold(
          appBar: AppBar(
            title: Text(destinations[selectedIndex].label),
            actions: [
              Semantics(
                label: widget.isDark ? 'Dark theme enabled' : 'Dark theme disabled',
                child: Row(children: [
                  Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
                  const SizedBox(width: 8),
                  CupertinoSwitch(value: widget.isDark, onChanged: widget.onDarkChanged),
                  const SizedBox(width: 16),
                ]),
              ),
            ],
          ),
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => setState(() => selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations.map((item) => NavigationRailDestination(icon: item.icon, selectedIcon: item.selectedIcon, label: Text(item.label))).toList(),
                ),
              Expanded(child: IndexedStack(index: selectedIndex, children: pages)),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => setState(() => selectedIndex = index),
                  destinations: destinations,
                ),
        );
      },
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({required this.onOpenProfile, super.key});
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeBanner(onOpenProfile: onOpenProfile),
              const SizedBox(height: 24),
              Text('This semester at a glance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 650 ? 2 : 1;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 3.2 : 2.3,
                    children: const [
                      MetricCard('Assignments', '8', '2 due this week', Icons.assignment_outlined),
                      MetricCard('Attendance', '92%', 'Above your target', Icons.event_available_outlined),
                      MetricCard('Portfolio', 'Ready', 'Updated today', Icons.folder_open_outlined),
                      MetricCard('Current week', '02', 'of 16 weeks', Icons.calendar_today_outlined),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;
                  final cards = const [_ProgressPanel(), _ActivityPanel()];
                  return wide
                      ? Row(children: [Expanded(child: cards[0]), const SizedBox(width: 14), Expanded(child: cards[1])])
                      : Column(children: [cards[0], const SizedBox(height: 14), cards[1]]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.onOpenProfile});
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Semantics(label: 'Alex Morgan profile photo', child: CircleAvatar(radius: 32, child: const Text('AM'))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning, Alex', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), const Text('Computer Science · Semester 4') ])),
          IconButton(tooltip: 'Open profile', onPressed: onOpenProfile, icon: const Icon(Icons.arrow_forward_rounded)),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard(this.title, this.value, this.caption, this.icon, {super.key});
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
          child: Row(children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.labelLarge), Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), Text(caption, style: theme.textTheme.bodySmall)])),
          ]),
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Semester progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: LinearProgressIndicator(value: .68, minHeight: 10)), const SizedBox(width: 12), const Text('68%')]),
          const SizedBox(height: 10),
          const Text('You are on track for your learning goals.'),
        ]),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: const [
        ListTile(leading: Icon(Icons.schedule_outlined), title: Text('Upcoming deadline'), subtitle: Text('HCI lab · Friday, 23:59')),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Portfolio review'), subtitle: Text('Completed today')),
      ]),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(padding: const EdgeInsets.all(24), children: [
      Center(child: CircleAvatar(radius: 46, child: Text('AM', style: theme.textTheme.headlineSmall))),
      const SizedBox(height: 14),
      Center(child: Text('Alex Morgan', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
      const Center(child: Text('alex.morgan@campus.test')),
      const SizedBox(height: 28),
      const _DetailTile(icon: Icons.school_outlined, title: 'Program', value: 'Computer Science'),
      const _DetailTile(icon: Icons.layers_outlined, title: 'Semester', value: '4 of 8'),
      const _DetailTile(icon: Icons.location_on_outlined, title: 'Campus', value: 'North Campus'),
    ]);
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value)));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.isDark, required this.onDarkChanged, required this.onLogout, super.key});
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Preferences', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Card(child: SwitchListTile.adaptive(title: const Text('Dark theme'), subtitle: const Text('Use a darker color scheme'), value: isDark, onChanged: onDarkChanged)),
      Card(child: const ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Notifications'), subtitle: Text('Assignments and deadline reminders'))),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout), label: const Text('Sign out')),
    ]);
  }
}
