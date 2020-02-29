import * as Roact from "@rbxts/roact"
import Loot from "shared/ReplicatedStorage/Core/Loot"

export type LootReward = Map<Loot.LootType, Map<Rarity, number[]>>

export type Difficulty = {
	MinLevel?: number,
	TimesPlayed?: number,

	Style: {
		Name: string,
		Color: Color3,
	},
}

export type Campaign = {
	Name: string,
	Image: string,
	LockedArena?: boolean,

	Difficulties: Difficulty[],
	Loot: LootReward,
}

export type Location = {
	Name: string,
	Image: string,
	Difficulties?: Difficulty[],
}

type CreateState = {
	campaignIndex: number,
	difficulty: number,
}

export type Gamemode = {
	Name: string,
	Locations: Location[],
	HardcoreEnabled: boolean,

	IsPlayable(campaignIndex: number, difficultyIndex: number, difficulty: Difficulty): LuaTuple<[boolean, number?]>,
	Submit(state: CreateState): object,
	ImageOverlay?(e: typeof Roact.createElement): Roact.Element
}
