import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:taskmanager/src/chores/chore.dart';

/// Entry point for the Discord bot.
class Bot {
  /// The Discord bot token.
  late final String token = Platform.environment['TOKEN']!;

  /// The channel ID to use for messaging.
  final channelId = Snowflake.parse('1511878270537437206');

  /// The nyxx client.
  late NyxxGateway client;

  /// Start the bot.
  Future<void> start() async {
    client = await Nyxx.connectGateway(token, GatewayIntents.allUnprivileged);
  }

  /// Stop the bot.
  Future<void> stop() async {
    await client.close();
  }

  Future<Member?> _getUserByUsername(String username) async {
    final channel = await client.channels.fetch(channelId) as GuildChannel;
    final guildId = channel.guildId;
    final searchResults = await client.guilds[guildId].members.search(
      username,
    );
    if (searchResults.isEmpty) return null;
    return searchResults.first;
  }

  /// Ping the responsible party for the chore.
  Future<void> pingForChore(Chore chore, List<String> guiltyParty) async {
    final guiltyMembers = (await Future.wait(
      guiltyParty.map(_getUserByUsername).toList(),
    )).where((e) => e != null).toList().cast<Member>();

    final partyString = guiltyMembers.map((e) => '<@${e.id.value}>').join(', ');
    final message =
        'Chore: ${chore.name}\n'
        'Description: ${chore.description}\n'
        'Party: $partyString';

    final channel = await client.channels.fetch(channelId) as TextChannel;
    await channel.sendMessage(
      MessageBuilder(
        content: message,
      ),
    );
  }
}
