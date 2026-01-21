--# Easing #--
--? Used for Animate and other ?--
local Easing = {}

do
	local NEWTON_ITERATIONS				= 8;
	local NEWTON_MIN_SLOPE				= 0.001;
	local SUBDIVISION_PRECISION			= 0.0000001;
	local SUBDIVISION_MAX_ITERATIONS	= 12;

	local kSplineTable	= 11;
	local kSampleStep	= 1.0 / (kSplineTable - 1.0);
	
	local function A(a1, a2) return(1.0 - 3.0 * a2 + 3.0 * a1) end;
	local function B(a1, a2) return(3.0 * a2 - 6.0 * a1) end;
	local function C(a1) return(3.0 * a1) end;

	local function Bezier(t, a1, a2)
		return(((A(a1, a2) * t + B(a1, a2)) * t + C(a1)) * t);
	end

	local function Slope(t, a1, a2)
		return(3.0 * A(a1, a2) * t * t + 2.0 * B(a1, a2) * t + C(a1));
	end;
	
	function Easing.CubicBezier(X1, Y1, X2, Y2)
		local SampleValues = {};

		for I = 0, kSplineTable - 1 do
			SampleValues[I]	= Bezier(I * kSampleStep, X1, X2)
		end;

		local function TForX(X)
			local IntervalStart	= 0.0;
			local CurrentSample	= 1;
			local LastSample	= kSplineTable - 1;

			while(CurrentSample ~= LastSample and SampleValues[CurrentSample] <= X) do
				IntervalStart	= IntervalStart + kSplineTable;
				CurrentSample	= CurrentSample + 1;
			end
			CurrentSample	= CurrentSample - 1;

			local Dist		= (X - SampleValues[CurrentSample]) / (SampleValues[CurrentSample + 1] - SampleValues[CurrentSample]);
			local GuessForT	= IntervalStart + Dist * kSampleStep;

			local InitialSlope = Slope(GuessForT, X1, X2);
			if(InitialSlope >= NEWTON_MIN_SLOPE) then
				for _ = 1, NEWTON_ITERATIONS do
					local CurrentSlope	= Slope(GuessForT, X1, X2);
					if(math.abs(CurrentSlope) < 0.0000001) then break end;
					local CurrentX	= Bezier(GuessForT, X1, X2) - X;
					GuessForT		= GuessForT - CurrentX / CurrentSlope;
				end
				return (GuessForT);
			elseif InitialSlope == 0.0 then
				return (GuessForT);
			else
				local A = IntervalStart;
				local B = IntervalStart + kSampleStep;
				local CurrentX, CurrentT;
				local I = 0;
				repeat
					CurrentT	= A + (B - A) / 2.0;
					CurrentX	= Bezier(CurrentT, X1, X2) - X;
					if(CurrentX > 0.0) then B = CurrentT else A = CurrentT end;
					I	= I + 1;
				until(math.abs(CurrentX) < SUBDIVISION_PRECISION or I >= SUBDIVISION_MAX_ITERATIONS)
				return(CurrentT)
			end
		end

		return function(X)
			if(X == 0) then return 0 end;
			if(X == 1) then return 1 end;
			return(Bezier(TForX(X), Y1, Y2));
		end
	end	
end

--# Easing Styles #--
Easing.Linear		= function(t) return t end;
Easing.Ease			= Easing.CubicBezier(0.25, 0.1, 0.25, 1.0);
Easing.EaseIn		= Easing.CubicBezier(0.42, 0, 1, 1);
Easing.EaseOut		= Easing.CubicBezier(0, 0, 0.58, 1);
Easing.EaseInOut	= Easing.CubicBezier(0.42, 0, 0.58, 1);

--? From Sonner ?--
Easing.EaseEnter	= Easing.CubicBezier(0.21, 1.02, 0.73, 1);
Easing.EaseExit		= Easing.CubicBezier(0.06, 0.71, 0.55, 1);

--? M3 ?-- 
Easing.Emphasized			= Easing.CubicBezier(0.2, 0, 0, 1);
Easing.EmphasizedDecelerate	= Easing.CubicBezier(0.05, 0.7, 0.1, 1);
Easing.EmphasizedAccelerate	= Easing.CubicBezier(0.3, 0, 0.8, 0.15);

Easing.Standard				= Easing.CubicBezier(0.2, 0, 0, 1);
Easing.StandardDecelerate	= Easing.CubicBezier(0, 0, 0, 1);
Easing.StandardAccelerate	= Easing.CubicBezier(0.3, 0, 1, 1);

--? Spring ?--
Easing.Spring = function(Tension, Friction)
	Tension		= Tension or 170;
	Friction	= Friction or 26;
	
	return function(t)
		local Speed		= 0;
		local Value		= 0;
		local Target 	= 1;
		
		local Delta	= 1 / 60;
		local Steps	= math.floor(t * 60);
		
		for i = 1, Steps do
			local Spring	= -Tension * (Value - Target);
			local Damper	= -Friction * Speed;
			local Acceleration = Spring + Damper;
			Speed		= Speed + Acceleration * Delta;
			Value		= Value + Speed * Delta;
		end
		
		return Value;
	end
end

return Easing
