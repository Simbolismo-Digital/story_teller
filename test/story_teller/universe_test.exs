defmodule StoryTeller.UniverseTest do
  use ExUnit.Case, async: false
  doctest StoryTeller.Universe

  test "universe opening scene" do
    # {:ok, scene, _story} = StoryTeller.Universe.opening_scene()
    {:ok, scene, _story} = universe_opening_scene()

    opening_scene =
      scene
      |> StoryTeller.Json.extract_json_block()
      |> Jason.decode!()
      |> StoryTeller.Scene.parse()

    assert opening_scene == built_opening_scene()
  end

  test "universe make actions" do
    acted_scene =
      built_opening_scene()
      |> StoryTeller.Action.make_actions(opening_story())

    assert acted_scene.actions == [
             %{character: "Lysandra", action: "Diz a Torvin: olá, meu amigo."}
           ]
  end

  # TODO: mock for expected behavior
  # warning: this test calls the API - avoid testing if not intended
  # test "universe next scene" do
  #   acted_scene =
  #     built_opening_scene()
  #     |> StoryTeller.Action.make_actions()

  #   {:ok, %StoryTeller.Scene{} = next_scene, _model_story} =
  #     results =
  #     acted_scene
  #     |> StoryTeller.Universe.next_scene(opening_story())

  #   assert next_scene.story == [acted_scene]
  # end

  defp built_opening_scene() do
    %StoryTeller.Scene{
      description:
        "O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.",
      location: "Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.",
      players: [
        %StoryTeller.Player{
          name: "Lysandra",
          race: "Elfa da Floresta",
          class: "Arqueira",
          equipment: nil,
          backstory:
            "Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário."
        },
        %StoryTeller.Player{
          name: "Torvin",
          race: "Anão da Montanha",
          class: "Guerreiro",
          equipment: nil,
          backstory:
            "Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos."
        },
        %StoryTeller.Player{
          name: "Zephyr",
          race: "Meio-elfo",
          class: "Mago",
          equipment: nil,
          backstory:
            "Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre."
        }
      ],
      npcs: [
        %StoryTeller.NPC{
          name: "Anya",
          race: "Sábia",
          description:
            "Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda."
        }
      ],
      items: [
        %StoryTeller.Item{
          name: "Cajado de Carvalho Ancião",
          description:
            "Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico."
        }
      ],
      story: [],
      actions: []
    }
  end

  defp universe_opening_scene() do
    {:ok,
     "```json\n{\n  \"scene\": {\n    \"description\": \"O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.\",\n    \"location\": \"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\n    \"players\": [\n      {\n        \"name\": \"Lysandra\",\n        \"race\": \"Elfa da Floresta\",\n        \"class\": \"Arqueira\",\n        \"backstory\": \"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"\n      },\n      {\n        \"name\": \"Torvin\",\n        \"race\": \"Anão da Montanha\",\n        \"class\": \"Guerreiro\",\n        \"backstory\": \"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"\n      },\n      {\n        \"name\": \"Zephyr\",\n        \"race\": \"Meio-elfo\",\n        \"class\": \"Mago\",\n        \"backstory\": \"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"\n      }\n    ],\n    \"npcs\":[\n        {\n            \"name\": \"Anya\",\n            \"race\": \"Sábia\",\n            \"description\": \"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\"\n        }\n    ],\n    \"items\": [\n      {\n        \"name\": \"Cajado de Carvalho Ancião\",\n        \"description\": \"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"\n      }\n    ]\n  }\n}\n```\n",
     opening_story()}
  end

  defp opening_story() do
    [
      %{
        parts: [
          %{
            text: StoryTeller.Universe.context()
          },
          %{text: "Generate the opening scene of a mythic RPG world."}
        ],
        role: "user"
      },
      %{
        parts: [
          %{
            text:
              "```json\n{\n  \"scene\": {\n    \"description\": \"O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.\",\n    \"location\": \"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\n    \"players\": [\n      {\n        \"name\": \"Lysandra\",\n        \"race\": \"Elfa da Floresta\",\n        \"class\": \"Arqueira\",\n        \"backstory\": \"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"\n      },\n      {\n        \"name\": \"Torvin\",\n        \"race\": \"Anão da Montanha\",\n        \"class\": \"Guerreiro\",\n        \"backstory\": \"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"\n      },\n      {\n        \"name\": \"Zephyr\",\n        \"race\": \"Meio-elfo\",\n        \"class\": \"Mago\",\n        \"backstory\": \"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"\n      }\n    ],\n    \"npcs\":[\n        {\n            \"name\": \"Anya\",\n            \"race\": \"Sábia\",\n            \"description\": \"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\"\n        }\n    ],\n    \"items\": [\n      {\n        \"name\": \"Cajado de Carvalho Ancião\",\n        \"description\": \"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"\n      }\n    ]\n  }\n}\n```\n"
          }
        ],
        role: "model"
      }
    ]
  end

  # def next_scene_mock() do
  #   {:ok,
  #     %StoryTeller.Scene{
  #       description: "Lysandra, Torvin e Zephyr se aproximam cautelosamente do círculo de pedras, seus passos suaves sobre a grama macia. Anya, a sábia, observa-os com seus olhos penetrantes, um leve sorriso nos lábios enrugados. O brilho suave das pedras parece intensificar à medida que os três se aproximam. O Cajado de Carvalho Ancião repousa ao lado de Anya, seu brilho rúnico pulsando fracamente.",
  #       location: "Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.",
  #       players: [
  #         %StoryTeller.Player{
  #           name: "Lysandra",
  #           race: "Elfa da Floresta",
  #           class: "Arqueira",
  #           equipment: nil,
  #           backstory: "Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário."
  #         },
  #         %StoryTeller.Player{
  #           name: "Torvin",
  #           race: "Anão da Montanha",
  #           class: "Guerreiro",
  #           equipment: nil,
  #           backstory: "Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos."
  #         },
  #         %StoryTeller.Player{
  #           name: "Zephyr",
  #           race: "Meio-elfo",
  #           class: "Mago",
  #           equipment: nil,
  #           backstory: "Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre."
  #         }
  #       ],
  #       npcs: [
  #         %StoryTeller.NPC{
  #           name: "Anya",
  #           race: "Sábia",
  #           description: "Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda."
  #         }
  #       ],
  #       items: [
  #         %StoryTeller.Item{
  #           name: "Cajado de Carvalho Ancião",
  #           description: "Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico."
  #         }
  #       ],
  #       story: [
  #         %StoryTeller.Scene{
  #           description: "O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.",
  #           location: "Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.",
  #           players: [
  #             %StoryTeller.Player{
  #               name: "Lysandra",
  #               race: "Elfa da Floresta",
  #               class: "Arqueira",
  #               equipment: nil,
  #               backstory: "Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário."
  #             },
  #             %StoryTeller.Player{
  #               name: "Torvin",
  #               race: "Anão da Montanha",
  #               class: "Guerreiro",
  #               equipment: nil,
  #               backstory: "Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos."
  #             },
  #             %StoryTeller.Player{
  #               name: "Zephyr",
  #               race: "Meio-elfo",
  #               class: "Mago",
  #               equipment: nil,
  #               backstory: "Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre."
  #             }
  #           ],
  #           npcs: [
  #             %StoryTeller.NPC{
  #               name: "Anya",
  #               race: "Sábia",
  #               description: "Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda."
  #             }
  #           ],
  #           items: [
  #             %StoryTeller.Item{
  #               name: "Cajado de Carvalho Ancião",
  #               description: "Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico."
  #             }
  #           ],
  #           story: [],
  #           actions: [
  #             %{character: "Lysandra", action: "Diz a Torvin: olá, meu amigo."}
  #           ]
  #         }
  #       ],
  #       actions: []
  #     },
  #     [
  #       %{
  #         parts: [
  #           %{
  #             text: "Você é um simulador de mundos de RPG. Retorne um JSON estruturado descrevendo uma cena e os personagens presentes.\n\nFormato:\n{\n  \"scene\": {\n    \"description\": \"...\",\n    \"location\": \"...\",\n    \"players\": [\n      {\n        \"name\": \"Drakaw\",\n        \"race\": \"Meio-dragão\",\n        \"class\": \"Bardo\",\n        \"backstory\": \"Fugiu do Circo de Lunei...\"\n      }\n    ]\n  }\n}\n\nEu vou seguir te respondendo em formato json, com a cena e as ações tomadas pelos personagens.\nE você continuará respondendo a próxima cena e nós repetiremos essa dinâmica.\n\nAgora, gere a cena de abertura de um mundo mítico de RPG.\n"
  #           },
  #           %{text: "Generate the opening scene of a mythic RPG world."}
  #         ],
  #         role: "user"
  #       },
  #       %{
  #         parts: [
  #           %{
  #             text: "```json\n{\n  \"scene\": {\n    \"description\": \"O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.\",\n    \"location\": \"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\n    \"players\": [\n      {\n        \"name\": \"Lysandra\",\n        \"race\": \"Elfa da Floresta\",\n        \"class\": \"Arqueira\",\n        \"backstory\": \"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"\n      },\n      {\n        \"name\": \"Torvin\",\n        \"race\": \"Anão da Montanha\",\n        \"class\": \"Guerreiro\",\n        \"backstory\": \"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"\n      },\n      {\n        \"name\": \"Zephyr\",\n        \"race\": \"Meio-elfo\",\n        \"class\": \"Mago\",\n        \"backstory\": \"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"\n      }\n    ],\n    \"npcs\":[\n        {\n            \"name\": \"Anya\",\n            \"race\": \"Sábia\",\n            \"description\": \"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\"\n        }\n    ],\n    \"items\": [\n      {\n        \"name\": \"Cajado de Carvalho Ancião\",\n        \"description\": \"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"\n      }\n    ]\n  }\n}\n```\n"
  #           }
  #         ],
  #         role: "model"
  #       },
  #       %{
  #         parts: [
  #           %{
  #             text: "{\"description\":\"O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.\",\"items\":[{\"name\":\"Cajado de Carvalho Ancião\",\"description\":\"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"}],\"location\":\"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\"players\":[{\"name\":\"Lysandra\",\"race\":\"Elfa da Floresta\",\"class\":\"Arqueira\",\"equipment\":null,\"backstory\":\"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"},{\"name\":\"Torvin\",\"race\":\"Anão da Montanha\",\"class\":\"Guerreiro\",\"equipment\":null,\"backstory\":\"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"},{\"name\":\"Zephyr\",\"race\":\"Meio-elfo\",\"class\":\"Mago\",\"equipment\":null,\"backstory\":\"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"}],\"npcs\":[{\"name\":\"Anya\",\"description\":\"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\",\"race\":\"Sábia\"}],\"story\":[],\"actions\":[{\"character\":\"Lysandra\",\"action\":\"Diz a Torvin: olá, meu amigo.\"}]}"
  #           }
  #         ],
  #         role: "user"
  #       },
  #       %{
  #         parts: [
  #           %{
  #             text: "```json\n{\n  \"scene\": {\n    \"description\": \"Lysandra, Torvin e Zephyr se aproximam cautelosamente do círculo de pedras, seus passos suaves sobre a grama macia. Anya, a sábia, observa-os com seus olhos penetrantes, um leve sorriso nos lábios enrugados. O brilho suave das pedras parece intensificar à medida que os três se aproximam. O Cajado de Carvalho Ancião repousa ao lado de Anya, seu brilho rúnico pulsando fracamente.\",\n    \"location\": \"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\n    \"players\": [\n      {\n        \"name\": \"Lysandra\",\n        \"race\": \"Elfa da Floresta\",\n        \"class\": \"Arqueira\",\n        \"equipment\": null,\n        \"backstory\": \"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"\n      },\n      {\n        \"name\": \"Torvin\",\n        \"race\": \"Anão da Montanha\",\n        \"class\": \"Guerreiro\",\n        \"equipment\": null,\n        \"backstory\": \"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"\n      },\n      {\n        \"name\": \"Zephyr\",\n        \"race\": \"Meio-elfo\",\n        \"class\": \"Mago\",\n        \"equipment\": null,\n        \"backstory\": \"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"\n      }\n    ],\n    \"npcs\": [\n      {\n        \"name\": \"Anya\",\n        \"race\": \"Sábia\",\n        \"description\": \"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\"\n      }\n    ],\n    \"items\": [\n      {\n        \"name\": \"Cajado de Carvalho Ancião\",\n        \"description\": \"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"\n      }\n    ],\n    \"story\": [\n      {\n        \"event\": \"Encontro com Anya na clareira.\"\n      }\n    ]\n  }\n}\n```\n"
  #           }
  #         ],
  #         role: "model"
  #       }
  #     ]}
  # end
end
