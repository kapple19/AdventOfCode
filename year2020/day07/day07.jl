struct Bag
	desc::Symbol
	colour::Symbol
	Bag(desc::Symbol, col::Symbol) = new(desc, col)
end

Bag(desc::AbstractString, col::AbstractString) = Bag(desc |> Symbol, col |> Symbol)

function Bag(bag::AbstractString)
	@assert [letter == ' ' for letter ∈ bag] |> sum == 1
	desc_col = split(bag, ' ')
	@assert desc_col |> length == 2
	Bag(desc_col[1], desc_col[2])
end

mutable struct Rule
	case::Bag
	contain::Vector{Tuple{Integer, Bag}}
end

function Rule(rule::AbstractString)
	rule_split = split(rule, ' ')
	rule_split |> typeof
	@assert rule_split[3] == "bags"
	case = Bag(rule_split[1], rule_split[2])
	rules = rule_split[5:end]
	if rules == ["no", "other", "bags."]
		return Rule(case, [])
	end
	Nrules = length(rules) / 4 |> Integer
	contain = Vector{Tuple{Integer, Bag}}(undef, 0)
	for n ∈ 1:Nrules
		int = tryparse(Int, rules[4n - 3])
		desc = rules[4n - 2]
		col = rules[4n - 1]
		@assert rules[4n][1:3] == "bag"
		push!(
			contain,
			(
				int,
				Bag(
					desc, col
				)
			)
		)
	end
	return Rule(case, contain)
end

all_rules = open("puzzle_input.txt") do file
	[Rule(rule) for rule ∈ eachline(file)]
end

## Part One

import Base.==
function ==(one::Bag, two::Bag)
	if one.desc ≠ two.desc
		return false
	elseif one.colour ≠ two.colour
		return false
	else
		return true
	end
end

all_bags = Vector{Bag}(undef, 0)
for rule ∈ all_rules
	if !any([rule.case == bag for bag ∈ all_bags])
		push!(all_bags, rule.case)
	end
	for rule_bag ∈ [contains[2] for contains ∈ rule.contain]
		if !any([rule_bag == bag for bag ∈ all_bags])
			push!(all_bags, rule_bag)
		end
	end
end

all_bag_contains = Vector{Tuple{Bag, Vector{Bag}}}(undef, 0)
for bag_children ∈ all_bags
	bag_parents = Vector{Bag}(undef, 0)
	for rule ∈ all_rules
		if [
			rule_cont_bag == bag_children for rule_cont_bag ∈ [
				quant[2] for quant ∈ rule.contain
			]
		] |> any
			push!(bag_parents, rule.case)
		end
	end
	push!(all_bag_contains, (bag_children, bag_parents))
end

contains_shiny_gold_bag = [Bag("shiny", "gold")]
Nbagscontain = 0
while Nbagscontain ≠ length(contains_shiny_gold_bag)
	Nbagscontain = length(contains_shiny_gold_bag)
	for bag_contains ∈ all_bag_contains
		if bag_contains[1] ∈ contains_shiny_gold_bag
			for bag_container ∈ bag_contains[2]
				if bag_container ∉ contains_shiny_gold_bag
					push!(contains_shiny_gold_bag, bag_container)
				end
			end
		end
	end
end
(contains_shiny_gold_bag |> length) - 1 |> println