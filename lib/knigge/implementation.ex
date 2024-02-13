defmodule Knigge.Implementation do
  @moduledoc """
  Internal module to work with the supplied implementation.

  Fetches the implementing modules based on the `Knigge.Options.implementation`
  value. Currently it supports passing the implementation directly or fetching
  it from the application environment.
  """

  alias Knigge.Options

  def fetch!(%Options{implementation: {:config, otp_app, [key | keys]}, default: default}) do
    module = otp_app |> Application.get_env(key) |> get_impl(keys)

    cond do
      is_nil(module) and is_nil(default) ->
        raise ArgumentError,
          message: """
          could not fetch application environment #{inspect([key | keys])} \
          for application #{inspect(otp_app)}\
          """

      is_nil(module) ->
        default

      true ->
        module
    end
  end

  def fetch!(%Options{implementation: implementation}) when is_atom(implementation) do
    implementation
  end

  def fetch_for!(module) do
    module
    |> Knigge.options!()
    |> Knigge.Implementation.fetch!()
  end

  defp get_impl(nil, _), do: nil
  defp get_impl(impl, []) when is_atom(impl), do: impl
  defp get_impl(data, keys), do: get_in(data, keys)
end
