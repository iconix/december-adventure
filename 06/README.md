# 12 06 2024

## adventure 06: generate absurd/whimsical pseudonyms

- today, i needed a piece of code to generate pseudonyms for my rc batch-mates. this will help me publish a blog post on a visualization about the batch that i created, without doxxing anyone
- my first instinct was to use [faker](https://faker.readthedocs.io/en/stable/). i've used it at work before, so i guess it has become my goto for easy fake data in python
- however, `faker` generates very realistic (read: boring) names via its [person provider](https://faker.readthedocs.io/en/stable/locales/en.html#faker.providers.person.en.Provider.name). these names were also surprisingly confusing to see in the visualization ('wait, who is Ralph Foster?! oh right, he is fake' x1000)
- now i more tangibly get the appeal of replit's `OverjoyedAromaticInformation` or whatever... but that flavor is still too much
- so i wrote one that is more cutesy and whimsical ft. animals, adjectives, colors, nature, and objects
- the code is straightforward and mostly reproduced below (i truncated the sub-lists of names, for brevity. but suffice to say, i ended up stealing a lot of [color names](https://github.com/joke2k/faker/blob/8a249d00f09db9911350449e9f5050a635b57fbb/faker/providers/color/__init__.py#L15) from faker in the end)
    ```python
    class Pseudonymizer:
    """Handles consistent pseudonym generation for names"""
    def __init__(self, seed: int = DEFAULT_SEED):
        self.animals = ['...']
        self.adjectives = ['...']
        self.colors = ['...']
        self.nature = ['...']
        self.objects = ['...']
        self.name_map = {}

    def generate_absurd_name(self) -> str:
        """Generate an absurd (whimsical) name using custom word lists"""
        # different styles of absurd names - randomly pick one
        styles = [
            # color + nature
            lambda: f"{random.choice(self.colors)} {random.choice(self.nature)}",
            # adjective + animal
            lambda: f"{random.choice(self.adjectives)} {random.choice(self.animals)}",
            # adjective + object
            lambda: f"{random.choice(self.adjectives)} {random.choice(self.objects)}",
        ]

        return random.choice(styles)()

    def get_pseudonym(self, real_name: str, preserve_names: Optional[List[str]] = None) -> str:
        """Returns consistent pseudonym for a given real name

        Args:
            real_name: The real name to pseudonymize
            preserve_names: Optional list of names to preserve unchanged
        """
        if preserve_names and real_name in preserve_names:
            return real_name

        if real_name not in self.name_map:
            # use hash of name to ensure consistent seeds per name
            name_hash = int(hashlib.md5(real_name.encode()).hexdigest(), 16)
            random.seed(name_hash)
            self.name_map[real_name] = self.generate_absurd_name()
            # go back to default seed after this process
            random.seed(DEFAULT_SEED)

        return self.name_map[real_name]
    ```
- one interesting thing that we do here is use a hash of the real name to seed the random number generator, so that the pseudonym stays consistent for that real name
- example pseudonyms: Sleepy Teapot, Linen Star, Swaying Kazoo, PeachPuff Forest
- [usage is here](https://github.com/iconix/rc-batch-viz/tree/09c19ffa3419fb1ba76e4aad5acf86555a44cf0c)
