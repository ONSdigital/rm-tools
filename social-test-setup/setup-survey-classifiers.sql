INSERT INTO survey.classifiertypeselector
(classifiertypeselectorpk, id, surveyfk, classifiertypeselector)
VALUES(35, 'ad804303-c2c3-4aa9-be65-b6e2cadd522d', 1000, 'COLLECTION_INSTRUMENT');

INSERT INTO survey.classifiertypeselector
(classifiertypeselectorpk, id, surveyfk, classifiertypeselector)
VALUES(36, 'bd804303-c2c3-4aa9-be65-b6e2cadd522d', 1000, 'COMMUNICATION_TEMPLATE');

INSERT INTO survey.classifiertype
(classifiertypepk, classifiertypeselectorfk, classifiertype)
VALUES(52, 35, 'COLLECTION_EXERCISE');

INSERT INTO survey.classifiertype
(classifiertypepk, classifiertypeselectorfk, classifiertype)
VALUES(53, 36, 'COLLECTION_EXERCISE');
