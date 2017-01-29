//: Playground - noun: a place where people can play

import UIKit

let numberOfGenomes = 8 // Flag for number of genomes

struct Genome {
    var nintey: Int
    var oneEighty: Int
    var twoSeventy: Int
    var zero: Int
    
    // Fitness score
    var score: Int
}

var population = [Genome]()
var generations = 0

// START REPETITION VARS

var numberOfTrials = 10 // Flag for number of trials
var currentTrial = 1

struct Trial {
    var time: Double
    var gens: Int
}

var isDone = false
var arrayOfTimes = [Trial]()

// END OF REPETITION VARS

var startingTime = Date()

var kittenStates = [Int]()

startAI()

func getNewPopulation() -> [Genome] {
    
    var arrayToReturn = [Genome]()
    
    for _ in 1 ... numberOfGenomes {
        // Init empty genome
        var newGenome = Genome(nintey: 0, oneEighty: 0, twoSeventy: 0, zero: 0, score: 0)
        
        for y in 1...4 {
            // Generate random of number of rotations - 0-100
            let whichRotation = Int(arc4random_uniform(21)+1)
            
            switch y {
            case 1:
                newGenome.nintey = whichRotation
            case 2:
                newGenome.oneEighty = whichRotation
            case 3:
                newGenome.twoSeventy = whichRotation
            case 4:
                newGenome.zero = whichRotation
            default:
                ()
            }
        }
        
        // Add genome to population
        arrayToReturn.append(newGenome)
    }
    //arrayToReturn.append(Genome(nintey: 5, oneEighty: 2, twoSeventy: 3, zero: 4, score: 0))
    return arrayToReturn
}

func restartAI() {
    population.removeAll()
    generations = 0
    
    startingTime = Date()
    
    currentTrial = currentTrial + 1
    
    if currentTrial == numberOfTrials + 1 {
        isDone = true
        for trial in arrayOfTimes {
            print(trial.time)
        }
        for trial in arrayOfTimes {
            print(trial.gens)
        }
    } else {
        startAI()
    }
}

func startAI() {
    if population.isEmpty {
        population = getNewPopulation()
    }
    initRandomFallingStates()
}


func initRandomFallingStates() {
    
    kittenStates.removeAll()
    
    for _ in 1...200 {
        let randomInt = Int(arc4random_uniform(4) + 1)
        kittenStates.append(randomInt)
    }
    
    for (index, genome) in population.enumerated() {
        if !isDone {
            evaluate(genome: genome, index: index)
            
            if index == numberOfGenomes - 1 {
                //print("reproduce")
                //print(population)
                reproduce()
            }
        }
    }
}


func evaluate(genome: Genome, index: Int) {
    
    var lives = 3
    var score = 0
    
    func evaluateLives() {
        lives = lives - 1
        
        if lives == 0 {
            // genome died
            population[index].score = score
            //print(score)
            return
        }
    }
    
    func evaluateScore() {
        score = score + 1
        
        if score == 150 {
            let newDate = Date().timeIntervalSince(startingTime)
            
            arrayOfTimes.append(Trial(time: newDate, gens: generations))
            print("done with trial \(currentTrial)")
            restartAI()
            return
        }
    }
    
    for state in kittenStates {
        switch state {
        case 1:
            // 90
            if (genome.nintey == 1) || (genome.nintey == 5) || (genome.nintey == 9) {
                evaluateScore()
            } else {
                evaluateLives()
            }
        case 2:
            // 180
            if (genome.oneEighty == 2) || (genome.oneEighty == 6) {
                evaluateScore()
            } else {
                evaluateLives()
            }
        case 3:
            // 270
            if (genome.twoSeventy == 3) || (genome.twoSeventy == 7) {
                evaluateScore()
            } else {
                evaluateLives()
            }
        case 4:
            // 0
            if (genome.zero == 4) || (genome.zero == 8) || (genome.zero == 0) {
                evaluateScore()
            } else {
                evaluateLives()
            }
        default:
            ()
        }
    }
}

func reproduce() {
    // Sort array based on score
    population.sort{ $0.score > $1.score }

    
    // Choose the two best genomes    
    let bestGenome = population[0]
    let secondBestGenome = population[1]
    
    crossOver(one: bestGenome, two: secondBestGenome)
}

func crossOver(one: Genome, two: Genome) {
    // Cross over at random
    
    var childrenPopulation = [Genome]()
    
    for _ in 1...(numberOfGenomes / 2) {
        
        var firstNewGenome = one
        var secondNewGenome = two
        
        // Reset score
        firstNewGenome.score = 0
        secondNewGenome.score = 0
        
        for y in 1...4 {
            if shouldCrossOver() {
                switch y {
                case 1:
                    // 90
                    let savedValueFromFirst = firstNewGenome.nintey
                    
                    firstNewGenome.nintey = secondNewGenome.nintey
                    secondNewGenome.nintey = savedValueFromFirst
                case 2:
                    // 180
                    let savedValueFromSecond = firstNewGenome.oneEighty
                    
                    firstNewGenome.oneEighty = secondNewGenome.oneEighty
                    secondNewGenome.oneEighty = savedValueFromSecond
                case 3:
                    // 270
                    let savedValueFromThird = firstNewGenome.twoSeventy
                    
                    firstNewGenome.twoSeventy = secondNewGenome.twoSeventy
                    secondNewGenome.twoSeventy = savedValueFromThird
                case 4:
                    // 0
                    let savedValueFromFourth = firstNewGenome.zero
                    
                    firstNewGenome.zero = secondNewGenome.zero
                    secondNewGenome.zero = savedValueFromFourth
                default:
                    ()
                }
            }
        }
        childrenPopulation.append(firstNewGenome)
        childrenPopulation.append(secondNewGenome)
    }
    
    mutate(newPopulation: childrenPopulation)
}

func shouldCrossOver() -> Bool {
    let random = Int(arc4random_uniform(2))
    
    var boolToReturn = false
    
    switch random {
    case 0:
        boolToReturn = false
    case 1:
        boolToReturn = true
    default:
        ()
    }
    
    return boolToReturn
}

func shouldMutate() -> Bool {
    let random = Int(arc4random_uniform(6))
    
    var boolToReturn = false
    
    switch random {
    case 1:
        boolToReturn = true
    default:
        boolToReturn = false
    }
    
    return boolToReturn
}

func mutate(newPopulation: [Genome]) {
    // SUBSTITUTION MUTATION
    
    // Assign the children to the population
    population.removeAll()
    population = newPopulation
    
    for (index, item) in population.enumerated() {
        for y in 1...4 {
            if shouldMutate() {
                var children = item
                let whichRotation = Int(arc4random_uniform(11)+1)
                
                switch y {
                case 1:
                    children.nintey = whichRotation
                case 2:
                    children.oneEighty = whichRotation
                case 3:
                    children.twoSeventy = whichRotation
                case 4:
                    children.zero = whichRotation
                default:
                    ()
                }
                
                population[index] = children
            }
        }
    }
    
    // Reset all the stuff
    //print("new population \(population)")
    generations = generations + 1
    initRandomFallingStates()
}
