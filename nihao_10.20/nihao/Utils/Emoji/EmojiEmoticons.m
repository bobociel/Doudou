//
//  EmojiEmoticons.m
//  Emoji
//
//  Created by Aliksandr Andrashuk on 26.10.12.
//  Copyright (c) 2012 Aliksandr Andrashuk. All rights reserved.
//

#import "EmojiEmoticons.h"

@implementation EmojiEmoticons

+ (NSArray *)allEmoticons {
    NSMutableArray *array = [NSMutableArray new];
    NSMutableArray * localAry = [[NSMutableArray alloc] initWithObjects:
								 [Emoji emojiWithCode:0x1f604],
								 [Emoji emojiWithCode:0x1f603],
								 [Emoji emojiWithCode:0x1f600],
								 [Emoji emojiWithCode:0x1f60a],
//								 [Emoji emojiWithCode:(char) 0x263a],
								 [Emoji emojiWithCode:0x1f609],
								 [Emoji emojiWithCode:0x1f60d],
								 [Emoji emojiWithCode:0x1f618],
								 [Emoji emojiWithCode:0x1f61a],
								 [Emoji emojiWithCode:0x1f617],
								 [Emoji emojiWithCode:0x1f619],
								 [Emoji emojiWithCode:0x1f61c],
								 [Emoji emojiWithCode:0x1f61d],
								 [Emoji emojiWithCode:0x1f61b],
								 [Emoji emojiWithCode:0x1f633],
								 [Emoji emojiWithCode:0x1f601],
								 [Emoji emojiWithCode:0x1f614],
								 [Emoji emojiWithCode:0x1f60c],
								 [Emoji emojiWithCode:0x1f612],
								 [Emoji emojiWithCode:0x1f61e],
								 [Emoji emojiWithCode:0x1f623],
								 [Emoji emojiWithCode:0x1f622],
								 [Emoji emojiWithCode:0x1f602],
								 [Emoji emojiWithCode:0x1f62d],
								 [Emoji emojiWithCode:0x1f62a],
								 [Emoji emojiWithCode:0x1f625],
								 [Emoji emojiWithCode:0x1f630],
								 [Emoji emojiWithCode:0x1f605],
								 [Emoji emojiWithCode:0x1f613],
								 [Emoji emojiWithCode:0x1f629],
								 [Emoji emojiWithCode:0x1f62b],
								 [Emoji emojiWithCode:0x1f628],
								 [Emoji emojiWithCode:0x1f631],
								 [Emoji emojiWithCode:0x1f620],
								 [Emoji emojiWithCode:0x1f621],
								 [Emoji emojiWithCode:0x1f624],
								 [Emoji emojiWithCode:0x1f616],
								 [Emoji emojiWithCode:0x1f606],
								 [Emoji emojiWithCode:0x1f60b],
								 [Emoji emojiWithCode:0x1f637],
								 [Emoji emojiWithCode:0x1f60e],
								 [Emoji emojiWithCode:0x1f634],
								 [Emoji emojiWithCode:0x1f635],
								 [Emoji emojiWithCode:0x1f632],
								 [Emoji emojiWithCode:0x1f61f],
								 [Emoji emojiWithCode:0x1f626],
								 [Emoji emojiWithCode:0x1f627],
								 [Emoji emojiWithCode:0x1f608],
								 [Emoji emojiWithCode:0x1f47f],
								 [Emoji emojiWithCode:0x1f62e],
								 [Emoji emojiWithCode:0x1f62c],
								 [Emoji emojiWithCode:0x1f610],
								 [Emoji emojiWithCode:0x1f615],
								 [Emoji emojiWithCode:0x1f62f],
								 [Emoji emojiWithCode:0x1f636],
								 [Emoji emojiWithCode:0x1f607],
								 [Emoji emojiWithCode:0x1f60f],
								 [Emoji emojiWithCode:0x1f611],
								 [Emoji emojiWithCode:0x1f472],
								 [Emoji emojiWithCode:0x1f473],
								 [Emoji emojiWithCode:0x1f46e],
								 [Emoji emojiWithCode:0x1f477],
								 [Emoji emojiWithCode:0x1f482],
								 [Emoji emojiWithCode:0x1f476],
								 [Emoji emojiWithCode:0x1f466],
								 [Emoji emojiWithCode:0x1f467],
								 [Emoji emojiWithCode:0x1f468],
								 [Emoji emojiWithCode:0x1f469],
								 [Emoji emojiWithCode:0x1f474],
								 [Emoji emojiWithCode:0x1f475],
								 [Emoji emojiWithCode:0x1f471],
								 [Emoji emojiWithCode:0x1f47c],
								 [Emoji emojiWithCode:0x1f478],
								 [Emoji emojiWithCode:0x1f63a],
								 [Emoji emojiWithCode:0x1f638],
								 [Emoji emojiWithCode:0x1f63b],
								 [Emoji emojiWithCode:0x1f63d],
								 [Emoji emojiWithCode:0x1f63c],
								 [Emoji emojiWithCode:0x1f640],
								 [Emoji emojiWithCode:0x1f63f],
								 [Emoji emojiWithCode:0x1f639],
								 [Emoji emojiWithCode:0x1f63e],
								 [Emoji emojiWithCode:0x1f479],
								 [Emoji emojiWithCode:0x1f47a],
								 [Emoji emojiWithCode:0x1f648],
								 [Emoji emojiWithCode:0x1f649],
								 [Emoji emojiWithCode:0x1f64a],
								 [Emoji emojiWithCode:0x1f480],
								 [Emoji emojiWithCode:0x1f47d],
								 [Emoji emojiWithCode:0x1f4a9],
								 [Emoji emojiWithCode:0x1f525],
//								 [Emoji emojiWithCode:(char) 0x2728],
								 [Emoji emojiWithCode:0x1f31f],
								 [Emoji emojiWithCode:0x1f4ab],
								 [Emoji emojiWithCode:0x1f4a5],
								 [Emoji emojiWithCode:0x1f4a2],
								 [Emoji emojiWithCode:0x1f4a6],
								 [Emoji emojiWithCode:0x1f4a7],
								 [Emoji emojiWithCode:0x1f4a4],
								 [Emoji emojiWithCode:0x1f4a8],
								 [Emoji emojiWithCode:0x1f442],
								 [Emoji emojiWithCode:0x1f440],
								 [Emoji emojiWithCode:0x1f443],
								 [Emoji emojiWithCode:0x1f445],
								 [Emoji emojiWithCode:0x1f444],
								 [Emoji emojiWithCode:0x1f44d],
								 [Emoji emojiWithCode:0x1f44e],
								 [Emoji emojiWithCode:0x1f44c],
								 [Emoji emojiWithCode:0x1f44a],
//								 [Emoji emojiWithCode:(char) 0x270a],
//								 [Emoji emojiWithCode:(char) 0x270c],
								 [Emoji emojiWithCode:0x1f44b],
//								 [Emoji emojiWithCode:(char) 0x270b],
								 [Emoji emojiWithCode:0x1f450],
								 [Emoji emojiWithCode:0x1f446],
								 [Emoji emojiWithCode:0x1f447],
								 [Emoji emojiWithCode:0x1f449],
								 [Emoji emojiWithCode:0x1f448],
								 [Emoji emojiWithCode:0x1f64c],
								 [Emoji emojiWithCode:0x1f64f],
//								 [Emoji emojiWithCode:(char) 0x261d],
								 [Emoji emojiWithCode:0x1f44f],
								 [Emoji emojiWithCode:0x1f4aa],
								 [Emoji emojiWithCode:0x1f6b6],
								 [Emoji emojiWithCode:0x1f3c3],
								 [Emoji emojiWithCode:0x1f483],
								 [Emoji emojiWithCode:0x1f46b],
								 [Emoji emojiWithCode:0x1f46a],
								 [Emoji emojiWithCode:0x1f46c],
								 [Emoji emojiWithCode:0x1f46d],
								 [Emoji emojiWithCode:0x1f48f],
								 [Emoji emojiWithCode:0x1f491],
								 [Emoji emojiWithCode:0x1f46f],
								 [Emoji emojiWithCode:0x1f646],
								 [Emoji emojiWithCode:0x1f645],
								 [Emoji emojiWithCode:0x1f481],
								 [Emoji emojiWithCode:0x1f64b],
								 [Emoji emojiWithCode:0x1f486],
								 [Emoji emojiWithCode:0x1f487],
								 [Emoji emojiWithCode:0x1f485],
								 [Emoji emojiWithCode:0x1f470],
								 [Emoji emojiWithCode:0x1f64e],
								 [Emoji emojiWithCode:0x1f64d],
								 [Emoji emojiWithCode:0x1f647],
								 [Emoji emojiWithCode:0x1f3a9],
								 [Emoji emojiWithCode:0x1f451],
								 [Emoji emojiWithCode:0x1f452],
								 [Emoji emojiWithCode:0x1f45f],
								 [Emoji emojiWithCode:0x1f45e],
								 [Emoji emojiWithCode:0x1f461],
								 [Emoji emojiWithCode:0x1f460],
								 [Emoji emojiWithCode:0x1f462],
								 [Emoji emojiWithCode:0x1f455],
								 [Emoji emojiWithCode:0x1f454],
								 [Emoji emojiWithCode:0x1f45a],
								 [Emoji emojiWithCode:0x1f457],
								 [Emoji emojiWithCode:0x1f3bd],
								 [Emoji emojiWithCode:0x1f456],
								 [Emoji emojiWithCode:0x1f458],
								 [Emoji emojiWithCode:0x1f459],
								 [Emoji emojiWithCode:0x1f4bc],
								 [Emoji emojiWithCode:0x1f45c],
								 [Emoji emojiWithCode:0x1f45d],
								 [Emoji emojiWithCode:0x1f45b],
								 [Emoji emojiWithCode:0x1f453],
								 [Emoji emojiWithCode:0x1f380],
								 [Emoji emojiWithCode:0x1f302],
								 [Emoji emojiWithCode:0x1f484],
								 [Emoji emojiWithCode:0x1f49b],
								 [Emoji emojiWithCode:0x1f499],
								 [Emoji emojiWithCode:0x1f49c],
								 [Emoji emojiWithCode:0x1f49a],
//								 [Emoji emojiWithCode:(char) 0x2764],
								 [Emoji emojiWithCode:0x1f494],
								 [Emoji emojiWithCode:0x1f497],
								 [Emoji emojiWithCode:0x1f493],
								 [Emoji emojiWithCode:0x1f495],
								 [Emoji emojiWithCode:0x1f496],
								 [Emoji emojiWithCode:0x1f49e],
								 [Emoji emojiWithCode:0x1f498],
								 [Emoji emojiWithCode:0x1f48c],
								 [Emoji emojiWithCode:0x1f48b],
								 [Emoji emojiWithCode:0x1f48d],
								 [Emoji emojiWithCode:0x1f48e],
								 [Emoji emojiWithCode:0x1f464],
								 [Emoji emojiWithCode:0x1f465],
								 [Emoji emojiWithCode:0x1f4ac],
								 [Emoji emojiWithCode:0x1f463],
								 [Emoji emojiWithCode:0x1f4ad],
                                 nil];
    [array addObjectsFromArray:localAry];
    //    for (int i=0x1F600; i<=0x1F64F; i++) {
    //        if (i < 0x1F641 || i > 0x1F644) {
    //            [array addObject:[Emoji emojiWithCode:i]];
    //        }
    //    }
    return array;
}

EMOJI_METHOD(grinningFace,1F600);
EMOJI_METHOD(grinningFaceWithSmilingEyes,1F601);
EMOJI_METHOD(faceWithTearsOfJoy,1F602);
EMOJI_METHOD(smilingFaceWithOpenMouth,1F603);
EMOJI_METHOD(smilingFaceWithOpenMouthAndSmilingEyes,1F604);
EMOJI_METHOD(smilingFaceWithOpenMouthAndColdSweat,1F605);
EMOJI_METHOD(smilingFaceWithOpenMouthAndTightlyClosedEyes,1F606);
EMOJI_METHOD(smilingFaceWithHalo,1F607);
EMOJI_METHOD(smilingFaceWithHorns,1F608);
EMOJI_METHOD(winkingFace,1F609);
EMOJI_METHOD(smilingFaceWithSmilingEyes,1F60A);
EMOJI_METHOD(faceSavouringDeliciousFood,1F60B);
EMOJI_METHOD(relievedFace,1F60C);
EMOJI_METHOD(smilingFaceWithHeartShapedEyes,1F60D);
EMOJI_METHOD(smilingFaceWithSunglasses,1F60E);
EMOJI_METHOD(smirkingFace,1F60F);
EMOJI_METHOD(neutralFace,1F610);
EMOJI_METHOD(expressionlessFace,1F611);
EMOJI_METHOD(unamusedFace,1F612);
EMOJI_METHOD(faceWithColdSweat,1F613);
EMOJI_METHOD(pensiveFace,1F614);
EMOJI_METHOD(confusedFace,1F615);
EMOJI_METHOD(confoundedFace,1F616);
EMOJI_METHOD(kissingFace,1F617);
EMOJI_METHOD(faceThrowingAKiss,1F618);
EMOJI_METHOD(kissingFaceWithSmilingEyes,1F619);
EMOJI_METHOD(kissingFaceWithClosedEyes,1F61A);
EMOJI_METHOD(faceWithStuckOutTongue,1F61B);
EMOJI_METHOD(faceWithStuckOutTongueAndWinkingEye,1F61C);
EMOJI_METHOD(faceWithStuckOutTongueAndTightlyClosedEyes,1F61D);
EMOJI_METHOD(disappointedFace,1F61E);
EMOJI_METHOD(worriedFace,1F61F);
EMOJI_METHOD(angryFace,1F620);
EMOJI_METHOD(poutingFace,1F621);
EMOJI_METHOD(cryingFace,1F622);
EMOJI_METHOD(perseveringFace,1F623);
EMOJI_METHOD(faceWithLookOfTriumph,1F624);
EMOJI_METHOD(disappointedButRelievedFace,1F625);
EMOJI_METHOD(frowningFaceWithOpenMouth,1F626);
EMOJI_METHOD(anguishedFace,1F627);
EMOJI_METHOD(fearfulFace,1F628);
EMOJI_METHOD(wearyFace,1F629);
EMOJI_METHOD(sleepyFace,1F62A);
EMOJI_METHOD(tiredFace,1F62B);
EMOJI_METHOD(grimacingFace,1F62C);
EMOJI_METHOD(loudlyCryingFace,1F62D);
EMOJI_METHOD(faceWithOpenMouth,1F62E);
EMOJI_METHOD(hushedFace,1F62F);
EMOJI_METHOD(faceWithOpenMouthAndColdSweat,1F630);
EMOJI_METHOD(faceScreamingInFear,1F631);
EMOJI_METHOD(astonishedFace,1F632);
EMOJI_METHOD(flushedFace,1F633);
EMOJI_METHOD(sleepingFace,1F634);
EMOJI_METHOD(dizzyFace,1F635);
EMOJI_METHOD(faceWithoutMouth,1F636);
EMOJI_METHOD(faceWithMedicalMask,1F637);
EMOJI_METHOD(grinningCatFaceWithSmilingEyes,1F638);
EMOJI_METHOD(catFaceWithTearsOfJoy,1F639);
EMOJI_METHOD(smilingCatFaceWithOpenMouth,1F63A);
EMOJI_METHOD(smilingCatFaceWithHeartShapedEyes,1F63B);
EMOJI_METHOD(catFaceWithWrySmile,1F63C);
EMOJI_METHOD(kissingCatFaceWithClosedEyes,1F63D);
EMOJI_METHOD(poutingCatFace,1F63E);
EMOJI_METHOD(cryingCatFace,1F63F);
EMOJI_METHOD(wearyCatFace,1F640);
EMOJI_METHOD(faceWithNoGoodGesture,1F645);
EMOJI_METHOD(faceWithOkGesture,1F646);
EMOJI_METHOD(personBowingDeeply,1F647);
EMOJI_METHOD(seeNoEvilMonkey,1F648);
EMOJI_METHOD(hearNoEvilMonkey,1F649);
EMOJI_METHOD(speakNoEvilMonkey,1F64A);
EMOJI_METHOD(happyPersonRaisingOneHand,1F64B);
EMOJI_METHOD(personRaisingBothHandsInCelebration,1F64C);
EMOJI_METHOD(personFrowning,1F64D);
EMOJI_METHOD(personWithPoutingFace,1F64E);
EMOJI_METHOD(personWithFoldedHands,1F64F);
@end
