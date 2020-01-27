import { Players, ReplicatedStorage, ServerScriptService, ServerStorage, StarterPlayer, Workspace } from "@rbxts/services"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import DungeonState from "mission/ServerScriptService/DungeonState"
import { Gamemode as GamemodeType, GamemodeConstructor } from "mission/ReplicatedStorage/GamemodeInfo/Gamemode"
import Gamemode from "./Gamemode"

const bossInfo = Dungeon.GetDungeonData("BossInfo")

function spawnBossRoom() {
	const rooms = new Instance("Folder")
	rooms.Name = "Rooms"

	const room = ServerStorage.BossRooms[bossInfo.RoomName].Clone()
	room.Name = "StartSection"
	room.Parent = rooms

	rooms.Parent = Workspace

	return room
}

const BossConstructor: GamemodeConstructor = {
	Init(this: void): GamemodeType {
		const bossRoom = spawnBossRoom()
		DungeonState.CurrentSpawn = bossRoom.FindFirstChild("SpawnLocation", true) as SpawnLocation

		for (const localScript of ServerScriptService.BossLocalScripts[bossInfo.RoomName].GetChildren()) {
			localScript.Clone().Parent = StarterPlayer.StarterPlayerScripts

			for (const player of Players.GetPlayers()) {
				localScript.Clone().Parent = player.WaitForChild("PlayerGui")
			}
		}

		return {
			Countdown(this: void, time) {
				if (time === 0) {
					const bossSequence = require(ReplicatedStorage.BossSequences[bossInfo.RoomName]) as BossSequence
					const position = (assert(
						bossRoom.FindFirstChild("BossSpawn", true),
						"No BossSpawn found",
					) as Attachment).WorldPosition

					const boss = Gamemode.SpawnBoss(bossSequence, position, bossRoom)
					boss.Died.Connect(Gamemode.EndMission)
				}
			},
		}
	},
}

export = BossConstructor
