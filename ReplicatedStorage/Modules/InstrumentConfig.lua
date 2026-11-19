return {
	NormalWalkSpeed = 8,
	FarWalkSpeed = 11,
	ZoneSlowdownDistance = 15,
	Instruments = {
		GuitarRhythm = {
			TemplateName = "GuitarRhythm_EquipModel",
			AttachPart = "UpperTorso",
			C0 = CFrame.new(
				-0.163367271,
				-0.656529427,
				-0.900413513,
				0.903741241,
				-0.335850775,
				0.265435696,
				-0.397466242,
				-0.888596475,
				0.228947356,
				0.158973083,
				-0.312410861,
				-0.936550617
			),
			GripAttachmentName = "GripAttachment",
			EquippedWalkSpeed = 5,
			CanWalkWhileEquipped = true,
			HoldingIdleAnimationId = "rbxassetid://115844071643337",
			CableRange = 17,
			CableJackAttachmentName = "CableJackAttachment",
			CableVisualSlack = 0.1
		},
		GuitarLead = {
			TemplateName = "GuitarLead_EquipModel",
			AttachPart = "UpperTorso",
			C0 = CFrame.new(
				-0.466461182,
				-0.411795139,
				-1.09721375,
				0.843490243,
				-0.373640478,
				0.385897636,
				-0.466980398,
				-0.865104735,
				0.183093473,
				0.265430689,
				-0.334644198,
				-0.904190183
			),
			GripAttachmentName = "GripAttachment",
			EquippedWalkSpeed = 5,
			CanWalkWhileEquipped = true,
			HoldingIdleAnimationId = "rbxassetid://118620279534754",
			CableRange = 20,
			CableJackAttachmentName = "CableJackAttachment",
			CableVisualSlack = 0.1
		},
		Bass = {
			TemplateName = "BassKayu_EquipModel",
			AttachPart = "UpperTorso",
			C0 = CFrame.new(
				-0.140426636,
				-0.973622799,
				-0.871255875,
				-0.865909457,
				-0.264479458,
				-0.424560487,
				0.437545598,
				-0.811809421,
				-0.386677444,
				-0.242393941,
				-0.520592153,
				0.81867528
			),
			GripAttachmentName = "GripAttachment",
			EquippedWalkSpeed = 5,
			CanWalkWhileEquipped = true,
			HoldingIdleAnimationId = "rbxassetid://139874956939075",
			CableRange = 18,
			CableJackAttachmentName = "CableJackAttachment",
			CableVisualSlack = 0.1
		},
		Drum = {
			SeatPartName = "Seat",
			HeldParts = {
				{
					TemplateName = "LeftDrumstick_EquipModel",
					AttachPart = "LeftHand",
					GripAttachmentName = "GripAttachment",
					C0 = CFrame.new(
						-3.81469727e-6,
						-0.119010925,
						-0.221054077,
						0.967037439,
						2.20216606e-7,
						-0.254634619,
						-3.2607926e-7,
						1,
						-3.73532146e-7,
						0.254634619,
						4.4425056e-7,
						0.967037439
					)
				},
				{
					TemplateName = "RightDrumstick_EquipModel",
					AttachPart = "RightHand",
					GripAttachmentName = "GripAttachment",
					C0 = CFrame.new(
						-0.0492401123,
						-0.145782471,
						-0.189735413,
						0.251095623,
						-1.21384971e-7,
						-0.967962325,
						1.70432017e-7,
						1,
						-8.11914305e-8,
						0.967962325,
						-1.44584959e-7,
						0.251095623
					)
				}
			},
			CanWalkWhileEquipped = false
		},
		Keyboard = { StandPointName = "StandPoint", CanWalkWhileEquipped = false },
		Piano = { SeatPartName = "Seat", HeldParts = {}, CanWalkWhileEquipped = false }
	}
}