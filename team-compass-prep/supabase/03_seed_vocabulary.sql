-- ============================================================================
-- Seed: 30 sample vocabulary items spanning L1..L5
--
-- This is the smallest viable set to drive a working "today's 20" demo.
-- Categories used: daily, school, soccer, general.
-- audio_url is left null for now; we'll backfill once we record native MP3s
-- and upload them to Supabase Storage at bucket "vocab-audio".
--
-- Idempotent: re-running this file will not create duplicates because of
-- the unique index on lower(word_en).
-- ============================================================================

insert into vocabulary_items (word_en, meaning_ja, pos, level, category, example_en, example_ja) values
  -- ----- L1 (super basic, Eiken 5/4) -----
  ('water',    '水',                 'noun', 1, 'daily',  'I drink water every day.',          '私は毎日水を飲みます。'),
  ('food',     '食べ物',             'noun', 1, 'daily',  'I like Japanese food.',             '私は日本食が好きです。'),
  ('friend',   '友達',               'noun', 1, 'daily',  'She is my best friend.',            '彼女は私の親友です。'),
  ('school',   '学校',               'noun', 1, 'school', 'I go to school by bus.',            '私はバスで学校へ行きます。'),
  ('happy',    '幸せな',             'adj',  1, 'daily',  'I am happy today.',                 '私は今日幸せです。'),
  ('run',      '走る',               'verb', 1, 'daily',  'I run every morning.',              '私は毎朝走ります。'),
  ('ball',     'ボール',             'noun', 1, 'soccer', 'Pass the ball, please!',            'ボールをパスして！'),

  -- ----- L2 (middle school basic, Eiken 4/3) -----
  ('play',     '(スポーツを)する・遊ぶ', 'verb', 2, 'soccer',  'I play soccer with my friends.',     '私は友達とサッカーをします。'),
  ('enjoy',    '楽しむ',             'verb', 2, 'daily',   'I enjoy reading books.',             '私は読書を楽しみます。'),
  ('practice', '練習する',           'verb', 2, 'soccer',  'We practice every day after school.','私たちは放課後毎日練習します。'),
  ('become',   '〜になる',            'verb', 2, 'general', 'I want to become a teacher.',        '私は先生になりたいです。'),
  ('important','重要な',             'adj',  2, 'general', 'It is important to study every day.','毎日勉強することは大切です。'),
  ('usually',  'たいてい',           'adv',  2, 'general', 'I usually wake up at seven.',        '私はたいてい7時に起きます。'),
  ('different','違った',             'adj',  2, 'general', 'We have different opinions.',        '私たちは違う意見を持っています。'),
  ('enough',   '十分な',             'adj',  2, 'general', 'I have enough money for lunch.',     'お昼ご飯のための十分なお金があります。'),

  -- ----- L3 (middle school complete, Eiken 3/Pre-2) -----
  ('between',    '〜の間に',         'prep', 3, 'general', 'Choose between tea and coffee.',     'お茶かコーヒーかの間で選んでください。'),
  ('decide',     '決める',           'verb', 3, 'general', 'I decided to study harder.',         '私はもっと勉強することに決めました。'),
  ('experience', '経験',             'noun', 3, 'general', 'It was a great experience.',         'それは素晴らしい経験でした。'),
  ('instead',    '代わりに',         'adv',  3, 'general', 'Let''s go to the park instead.',     '代わりに公園に行きましょう。'),
  ('recently',   '最近',             'adv',  3, 'general', 'I have been busy recently.',         '最近忙しいです。'),
  ('opportunity','機会',             'noun', 3, 'general', 'This is a great opportunity.',       'これは素晴らしい機会です。'),
  ('improve',    '改善する',         'verb', 3, 'general', 'I want to improve my English.',      '私は英語を上達させたいです。'),

  -- ----- L4 (high school standard, Eiken 2) -----
  ('although',   '〜だけれども',     'conj', 4, 'general', 'Although it rained, we went out.',   '雨が降ったけれども、私たちは出かけました。'),
  ('acquire',    '習得する・取得する','verb',4, 'general', 'She acquired new skills quickly.',   '彼女は新しい技能を素早く習得しました。'),
  ('sufficient', '十分な',           'adj',  4, 'general', 'We have sufficient time to prepare.','準備するための十分な時間があります。'),
  ('contribute', '貢献する',         'verb', 4, 'general', 'He contributed to the team''s win.', '彼はチームの勝利に貢献しました。'),
  ('ensure',     '確実にする',       'verb', 4, 'general', 'Please ensure the door is locked.',  'ドアが施錠されていることを確認してください。'),

  -- ----- L5 (advanced, Eiken Pre-1) -----
  ('perspective','視点',             'noun', 5, 'general', 'Try looking from a new perspective.','新しい視点で見てみてください。'),
  ('substantial','相当な',           'adj',  5, 'general', 'There was a substantial improvement.','相当な改善がありました。'),
  ('deteriorate','悪化する',         'verb', 5, 'general', 'His health began to deteriorate.',   '彼の健康は悪化し始めました。')
on conflict do nothing;
