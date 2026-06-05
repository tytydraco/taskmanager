import 'package:taskmanager/taskmanager.dart';

Future<void> main(List<String> arguments) async {
  final bot = Bot();
  await bot.start();

  final choreManager = ChoreManager();
  final matchingChores = choreManager.getTodaysChores();
  for (final chore in matchingChores) {
    final guiltyParty = choreManager.guiltyPartyForChore(chore);
    print('${chore.name} : $guiltyParty');
    await bot.pingForChore(chore, guiltyParty);
  }

  await bot.stop();
}
