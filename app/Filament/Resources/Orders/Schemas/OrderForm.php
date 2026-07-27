<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class OrderForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('user_id')
                    ->required()
                    ->numeric(),
                TextInput::make('driver_id')
                    ->numeric()
                    ->default(null),
                TextInput::make('item_name')
                    ->required(),
                TextInput::make('pickup_location')
                    ->required(),
                TextInput::make('destination_location')
                    ->required(),
                TextInput::make('fee')
                    ->required()
                    ->numeric(),
                Select::make('status')
                    ->options([
            'pending' => 'Pending',
            'accepted' => 'Accepted',
            'picked_up' => 'Picked up',
            'completed' => 'Completed',
            'cancelled' => 'Cancelled',
        ])
                    ->default('pending')
                    ->required(),
                FileUpload::make('proof_image')
                    ->image(),
                TextInput::make('payment_method')
                    ->required()
                    ->default('Cash'),
                TextInput::make('pickup_lat')
                    ->numeric()
                    ->default(null),
                TextInput::make('pickup_lng')
                    ->numeric()
                    ->default(null),
                TextInput::make('dest_lat')
                    ->numeric()
                    ->default(null),
                TextInput::make('dest_lng')
                    ->numeric()
                    ->default(null),
            ]);
    }
}
