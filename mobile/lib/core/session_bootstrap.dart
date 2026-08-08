/// Resolves the local user session before showing the real app shell.
/// Shows a loading spinner while bootstrapping, and a retry-capable
/// error screen if the backend is unreachable (e.g. forgot to start
/// uvicorn) — this is the app's actual entry point now, replacing the
/// old static HomePlaceholder that required manual editing to test
/// anything.
library;

import 'package:flutter/material.dart';

import '../features/home/home_shell.dart';
import 'user_session.dart';

class SessionBootstrap extends StatefulWidget {
  const SessionBootstrap({super.key});

  @override
  State<SessionBootstrap> createState() => _SessionBootstrapState();
}

class _SessionBootstrapState extends State<SessionBootstrap> {
  late Future<String> _userIdFuture;

  @override
  void initState() {
    super.initState();
    _userIdFuture = UserSession.resolveUserId();
  }

  void _retry() {
    setState(() {
      _userIdFuture = UserSession.resolveUserId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not connect to the server. Make sure the backend is running.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          );
        }

        return HomeShell(userId: snapshot.data!);
      },
    );
  }
}
