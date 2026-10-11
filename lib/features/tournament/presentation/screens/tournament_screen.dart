import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/skeleton.dart';
import 'package:screw_calculator/features/tournament/domain/entities/tournament.dart';
import 'package:screw_calculator/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TournamentCubit>(
      create: (_) => sl<TournamentCubit>(),
      child: const _TournamentView(),
    );
  }
}

class _TournamentView extends StatelessWidget {
  const _TournamentView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: l10n.tournamentTitle),
      bottomNavigationBar: const BottomNavigationText(),
      body: Directionality(
        textDirection: context.contentDirection,
        child: BlocBuilder<TournamentCubit, TournamentState>(
          builder: (context, state) {
            if (state.loading) {
              return const SkeletonList();
            }
            final t = state.tournament;
            return t == null ? const _CreateForm() : _Standings(tournament: t);
          },
        ),
      ),
    );
  }
}

class _CreateForm extends StatefulWidget {
  const _CreateForm();

  @override
  State<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<_CreateForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _players = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _players.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    final ok = await context.read<TournamentCubit>().create(
      _name.text.isEmpty ? l10n.tournamentTitle : _name.text,
      _players.text,
    );
    if (!ok && mounted) {
      Utilities().showCustomSnack(context, txt: l10n.tournamentInvalidPlayers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: l10n.tournamentNameLabel),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _players,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: l10n.tournamentPlayersLabel,
            hintText: l10n.tournamentPlayersHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        CustomText(
          text: l10n.tournamentRulesNote,
          fontSize: 14,
          color: context.palette.textSecondary,
        ),
        const SizedBox(height: 24),
        CustomButton(text: l10n.tournamentStart, onPressed: _start),
      ],
    );
  }
}

class _Standings extends StatelessWidget {
  const _Standings({required this.tournament});

  final Tournament tournament;

  Future<void> _addGame(BuildContext context) async {
    final cubit = context.read<TournamentCubit>();
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => _GameDialog(
        players: tournament.players,
        gameNumber: tournament.games.length + 1,
      ),
    );
    if (result != null) await cubit.addGame(result);
  }

  Future<void> _end(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TournamentCubit>();
    final confirm = await showAppConfirmDialog(
      context,
      icon: Icons.flag_rounded,
      tone: AppDialogTone.danger,
      title: l10n.tournamentEnd,
      message: l10n.tournamentEndConfirm,
    );
    if (confirm ?? false) await cubit.end();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final standings = computeStandings(tournament);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomText(text: tournament.name, fontSize: 22),
        const SizedBox(height: 4),
        CustomText(
          text: l10n.tournamentGamesPlayed(tournament.games.length),
          fontSize: 14,
          color: palette.textSecondary,
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < standings.length; i++)
          _StandingTile(rank: i + 1, standing: standings[i]),
        const SizedBox(height: 8),
        CustomText(
          text: l10n.tournamentRulesNote,
          fontSize: 13,
          color: palette.textSecondary,
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: l10n.tournamentAddGame,
          onPressed: () => _addGame(context),
        ),
        if (tournament.games.isNotEmpty)
          TextButton(
            onPressed: () => context.read<TournamentCubit>().removeLastGame(),
            child: Text(l10n.tournamentRemoveLast),
          ),
        TextButton(
          onPressed: () => _end(context),
          child: Text(
            l10n.tournamentEnd,
            style: TextStyle(color: palette.lose),
          ),
        ),
      ],
    );
  }
}

class _StandingTile extends StatelessWidget {
  const _StandingTile({required this.rank, required this.standing});

  final int rank;
  final Standing standing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final leader = rank == 1 && standing.points > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: leader
            ? Color.alphaBlend(
                palette.win.withValues(alpha: 0.12),
                palette.surface,
              )
            : palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: leader ? palette.win : palette.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: CustomText(text: leader ? '👑' : '$rank', fontSize: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: standing.name,
                  fontSize: 18,
                  textAlign: TextAlign.start,
                ),
                CustomText(
                  text:
                      '${l10n.wins} ${standing.wins} · ${l10n.played} ${standing.games}',
                  fontSize: 13,
                  color: palette.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          CustomText(
            text: '${standing.points} ${l10n.tournamentPoints}',
            fontSize: 20,
            color: palette.brandSoft,
          ),
        ],
      ),
    );
  }
}

class _GameDialog extends StatefulWidget {
  const _GameDialog({required this.players, required this.gameNumber});

  final List<String> players;
  final int gameNumber;

  @override
  State<_GameDialog> createState() => _GameDialogState();
}

class _GameDialogState extends State<_GameDialog> {
  late final List<TextEditingController> _controllers = [
    for (final _ in widget.players) TextEditingController(),
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      for (var i = 0; i < widget.players.length; i++)
        widget.players[i]: int.parse(_controllers[i].text.trim()),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.tournamentGameResultTitle(widget.gameNumber)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.players.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextFormField(
                    controller: _controllers[i],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.players[i]),
                    validator: (v) => int.tryParse((v ?? '').trim()) == null
                        ? l10n.tournamentInvalidScore
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.tournamentSave)),
      ],
    );
  }
}
